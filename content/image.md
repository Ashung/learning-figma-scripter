# 位图

## ImagePaint 和 Image 对象

在 Figma 中没有真正意义上的位图类型图层，其本质是一个形状上的位图填充，填充中含有 ImagePaint 类型的项图层列表就显示为位图图层 。

```typescript
// Figma Plugin API Typings
interface ImagePaint {
  readonly type: "IMAGE"
  readonly scaleMode: "FILL" | "FIT" | "CROP" | "TILE"
  readonly imageHash: string | null
  readonly imageTransform?: Transform // setting for "CROP"
  readonly scalingFactor?: number // setting for "TILE"
  readonly filters?: ImageFilters
  readonly visible?: boolean
  readonly opacity?: number
  readonly blendMode?: BlendMode
}

interface Image {
  readonly hash: string
  getBytesAsync(): Promise<Uint8Array>
}
```

创建一个位图图层，实际上是先创建一个矩形或其他形状，然后添加 ImagePaint，而 ImagePaint 对象的最主要属性是 imageHash。当位图被保存到 Figma 文档中时，Figma 为每个图片创建一个 ID 来复用图像，这个 ID 就是 imageHash。要获取 imageHash，在真实插件环境中使用 `figma.createImage(data: Uint8Array) ` 获得 Image 对象，参数 Uint8Array 是通过插件 UI 去请求网络上的图片或者用户上传本地图片而转换来的。Image 对象创建成功后 Figma 即会将保存图片保存下来，然后将 Image.hash 赋予 ImagePaint 对象的 imageHash 属性。

```typescript
// Figma Plugin API Typings
interface PluginAPI {
  // ...
  createImage(data: Uint8Array): Image
  getImageByHash(hash: string): Image
  // ...
}
```

## 插入位图

由于受 Scripter 的环境限制，用户无法通过上传读取图片数据，为此 Scripter 增加了 `Img()` 函数来从网络获取 Figma 支持的图片，并且可以使用 `print(Img())` 在编辑器中预览。 `Img()` 函数不支持本地 url。

```typescript
print(Img('https://scripter.rsms.me/icon.png'));
```

从声明文件看出 `Img()` 返回 Img 对象，可接受 data 或 url 作为第一个参数，ImgOptions 作为可选的第二个参数，这个参数目前发现并不会对实际图片缩放，只影响由 `Img.toRectangle()` 创建的矩形大小。

```typescript
// Scripter Typings
interface ImgOptions {
  type?   :string  // mime type
  width?  :number
  height? :number
}
interface ImgConstructor {
  new(data :ArrayBufferLike|Uint8Array|ArrayLike<number>, optionsOrWidth? :ImgOptions|number): Img<Uint8Array>;
  new(url :string, optionsOrWidth? :ImgOptions|number): Img<null>;
  (data :ArrayBufferLike|Uint8Array|ArrayLike<number>, optionsOrWidth? :ImgOptions|number): Img<Uint8Array>;
  (url :string, optionsOrWidth? :ImgOptions|number): Img<null>;
}
declare var Img: ImgConstructor;
```

Img 对象通过 `toRectangle()` 方法直接创建带有图片填充的矩形，或者通过 `getImage()` 获得 Image 对象。

```typescript
// Scripter Typings
interface Img<DataType=null|Uint8Array> {
  type        :string      // mime type
  width       :number      // 0 means "unknown"
  height      :number      // 0 means "unknown"
  pixelWidth  :number      // 0 means "unknown"
  pixelHeight :number      // 0 means "unknown"
  source      :string|Uint8Array // url or image data
  data        :DataType    // image data if loaded
  /** Type-specific metadata. Populated when image data is available. */
  meta :{[k:string]:any}
  /** Load the image. Resolves immediately if source is Uint8Array. */
  load() :Promise<Img<Uint8Array>>
  /** Get Figma image. Cached. Calls load() if needed to load the data. */
  getImage() :Promise<Image>
  /** Create a rectangle node with the image as fill, scaleMode defaults to "FIT". */
  toRectangle(scaleMode? :"FILL" | "FIT" | "CROP" | "TILE") :Promise<RectangleNode>
}
```

Scripter 提供了另一个从网上获取图片的 `fetchImg()` 函数。

```typescript
// Scripter Typings
/** Shorthand for fetchData().then(data => Img(data)) */
declare function fetchImg(input: RequestInfo, init?: RequestInit): Promise<Img>;
```

使用 `Img.toRectangle()` 方法插入图片。

```typescript
let image = Img('https://scripter.rsms.me/icon.png', {width: 100, height: 100});
let layer = await image.toRectangle('FILL');
addToPage(layer);
```

如果要将图片插入到其他形状图层，则需要将 `Img` 对象转为 `Image` 对象，在得到 `imageHash`，由此创建 `ImagePaint`，然后将此设为形状的填充。

```typescript
let img = Img('https://scripter.rsms.me/icon.png');
let image = await img.getImage();
let layer = Ellipse({
  x: 0,
  y: 0,
  width: 40,
  height: 40,
  arcData: {
    startingAngle: 0,
    endingAngle: Math.PI * 2,
    innerRadius: 0
  },
  fills: [{
    type: 'IMAGE',
    scaleMode: 'FILL',
    imageHash: image.hash
  }]
});
addToPage(layer);
```

## 修改位图

### 缩放模式

修改选中图层中位图图层的缩放模式，值可为 `"FILL" | "FIT" | "CROP" | "TILE"`。

```typescript
// Loop over images in the selection
for (let shape of await find(selection(), n => isImage(n) && n)) {
  // Update image paints to use "FIT" scale mode
  shape.fills = shape.fills.map(p =>
    isImage(p) ? {...p, scaleMode: "FIT"} : p)
}
```

### 替换内容

替换内容即是修改 `imageHash`，示例中，使用 [tinyfaces](https://tinyfac.es/) 开放的 API 提取用户头像随机填充到选中的图层中。

```typescript
let json = await fetchJson('https://tinyfac.es/api/users');
let avatars = json.map(item => {
  return item.avatars[0].url;
});
for (let layer of selection()) {
  let img = Img(avatars[Math.floor(Math.random() * avatars.length)]);
  let image = await img.getImage();
  (layer as GeometryMixin).fills = [{
    type: 'IMAGE',
    scaleMode: 'FILL',
    imageHash: image.hash
  }];
}
```

使用并行下载，速度较快，但某些服务器可能会限制最大并发数。

```typescript
let json = await fetchJson('https://tinyfac.es/api/users');
let avatars = Array(selection().length).fill(0).map(val => {
  let url = json[Math.floor(Math.random() * json.length)].avatars[0].url;
  return Img(url).getImage();
});
Promise.all(avatars).then((images: Image[]) => {
  selection().forEach((n, i) => {
    (n as GeometryMixin).fills = [{
      type: 'IMAGE',
      scaleMode: 'FILL',
      imageHash: images[i].hash
    }];
  });
});
```

### 位图平铺缩放

位图平铺通常用在连续的图案背景，或者添加某种材质纹理，在 [Subtle Patterns](https://www.toptal.com/designers/subtlepatterns/) 可以找到很多可连续的图案。

为选中的 1 个图层添加可平铺的图案，当 `scaleMode` 值为 `TILE` 时，`scalingFactor` 才会生效，值为 0 - 1 对应界面上的 0 - 100%。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let pattern = Img('https://www.toptal.com/designers/subtlepatterns/wp-content/themes/tweaker7/images/transp_bg.png');
let image = await pattern.getImage();
layer.fills = [{
  type: 'IMAGE',
  scaleMode: 'TILE',
  scalingFactor: 0.5,
  imageHash: image.hash
}];
```

### 位图滤镜

`ImageFilters` 的每个属性值范围为 -1 - 1，默认值为 0。声明 `ImageFilters` 时不需要为所有属性赋值。

```typescript
// Figma Plugin API Typings
interface ImageFilters {
  readonly exposure?: number
  readonly contrast?: number
  readonly saturation?: number
  readonly temperature?: number
  readonly tint?: number
  readonly highlights?: number
  readonly shadows?: number
}
```

修改选中图层中位图图层的位图滤镜，将 `ImageFilters.saturation` 设为 -1 可将图片改为灰度。

```typescript
for (let shape of await find(selection(), n => isImage(n) && n)) {
  shape.fills = shape.fills.map(p =>
    isImage(p) ? {...p, filters: {saturation: -1}} : p)
}
```

重置位图滤镜，即给 `ImagePaint.filters` 赋予一个空对象，而不需要声明一个所有属性均为 0 的 `ImageFilters`。

```typescript
for (let shape of await find(selection(), n => isImage(n) && n)) {
  shape.fills = shape.fills.map(p =>
    isImage(p) ? {...p, filters: {}} : p)
}
```

## 栅格化图层

Figma 没有栅格化选择图层的 API，另外界面上的栅格化选择图层会将图层转为 1x 位图。栅格化选择图层利用将图层组合之后，获取图层的 PNG 数据，并设置放大倍数，然后创建一个与组相同位置和尺寸的矩形，将 PNG 数据做为矩形的填充。

```typescript
let selectedLayers = figma.currentPage.selection;
if (selectedLayers.length > 0) {
  let parent = selectedLayers[0].parent as (BaseNode & ChildrenMixin);
  let group = figma.group(selectedLayers, parent);
  let exportSettings: ExportSettingsImage = {
    format: 'PNG',
    constraint: {
      type: 'SCALE',
      value: 2
    }
  };
  let data = await group.exportAsync(exportSettings);
  let image = figma.createImage(data);
  let rectangle = figma.createRectangle();
  rectangle.x = group.x;
  rectangle.y = group.y;
  rectangle.resize(group.width, group.height);
  rectangle.fills = [
    {
      type: 'IMAGE',
      scaleMode: 'FILL',
      imageHash: image.hash
    }
  ];
  parent.appendChild(rectangle);
  group.remove();
}
```

