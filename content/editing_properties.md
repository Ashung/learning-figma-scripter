# 编辑属性

## 修改属性值

在 Figma Plugin API 文档内或声明文件中，那些没有标记 `readonly` 的对象属性，可以通过直接为属性赋予新的值来实现编辑属性。

从声明文件中的 `LayoutMixin` 接口可以看出图层的坐标都是非 Readonly 的，而图层的宽高则被标记了 Readonly。

```typescript
// Figma Plugin API Typings
interface LayoutMixin {
  // ...
  x: number
  y: number
  
  readonly width: number
  readonly height: number
  
  resize(width: number, height: number): void
  resizeWithoutConstraints(width: number, height: number): void
}
```

如果要改变图层的坐标，可以直接修改 x 或 y 的属性。选中一个图层，运行下面的代码，图层将向右移动 8 像素。

```typescript
let layer = figma.currentPage.selection[0];
layer.x += 8;
```

将图层移动到坐标 (0, 0) 的位置。

```typescript
let layer = figma.currentPage.selection[0];
layer.x = 0;
layer.y = 0;
```

图层的宽高是 Readonly 值, 如果想通过下面的代码放大图层，将会提示出错。

```typescript
let layer = figma.currentPage.selection[0];
layer.width *= 2; // 错误
layer.height *= 2; // 错误
```

修改图层的宽高，需要通过 resize 或 resizeWithoutConstraints 2 个方法来实现。

```typescript
let layer = figma.currentPage.selection[0];
layer.resize(layer.width * 2, layer.height * 2);
```

## 数组拷贝

某些非 Readonly 属性的值为 ReadonlyArray 类型，修改这种属性不能直接修改值的数组，必须从原来的值拷贝一个新的数组，对新的数组进行更改后再赋值给这个属性。选中图层、填充、描边等等都是这种类型。

```typescript
// Figma Plugin API Typings
interface PageNode extends BaseNodeMixin, ChildrenMixin, ExportMixin {
  // ...
	selection: ReadonlyArray<SceneNode>
  // ...
}

interface GeometryMixin {
  fills: ReadonlyArray<Paint> | PluginAPI['mixed']
  strokes: ReadonlyArray<Paint>
  // ...
}
```

通过下面的方式增加选中图层和修改图层填充，都会导致程序报错。

```typescript
figma.currentPage.selection.push(SceneNode)
GeometryMixin.fills[0].color = {r:0, g:0, b:0}
```

使用 `array.slice()`，`array.concat()` 和  `array.map()` 方法都可以返回一个新的数组。例如选中一个图层，为图层添加一个红色填充，可以通过下面几种方式，含有多种颜色的文本图层不适合这种方法。

使用较原始的方法先创建一个空数组，再将现有数组的元素填到空数组内。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills: Paint[] = [];
for (let paint of (layer.fills as Paint[])) {
  newFills.push(paint);
}
newFills.push(RED.paint)
layer.fills = newFills;
```

使用 `slice()` 方法拷贝数组，通过参数可以实现提取数组的某一段，例如 `slice(1)` 表示删除第一项，`slice(0, array.length - 1)` 表示删除最后一项，`slice(0, 1)` 表示只留第一项，`slice(-1)` 表示只留最后一项。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills = (layer.fills as Paint[]).slice();
newFills.push(RED.paint)
layer.fills = newFills;
```

使用 `concat()` 方法拷贝数组，也可以用于多个数组合并，如果参数是另一个图层的 fills 数组，就是将多个图层的填充合并。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).concat(RED.paint);
```

使用解构赋值创建新的数组。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = [...(layer.fills as Paint[]), RED.paint];
```

## 对象拷贝

上面的例子只是增加或删除填充，并没有修改填充项的值，由于作为填充项的 SolidPaint、 GradientPaint、ImagePaint 的所有属性都是 Readonly 的，如果要修改填充项属性就要涉及对象拷贝。

这个代码打算将选中图层的填充改为反色，但由于 Paint 的所有属性都是 Readonly 的，所以程序会报错。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills = (layer.fills as Paint[]).slice();
for (let paint of newFills) {
  if (paint.type === 'SOLID') {
    paint.color.r = 1 - paint.color.r; // 提示 r is read-only
    paint.color.g = 1 - paint.color.g; // 提示 g is read-only
    paint.color.b = 1 - paint.color.b; // 提示 b is read-only
  }
}
layer.fills = newFills;
```

对象拷贝，除了原始的创建新对象在逐一赋值外，通常使用以下 3 种方式。

```typescript
// JSON 解析
JSON.parse(JSON.stringify(object));
// 合并对象
Object.assign({}, object);
// 结构赋值
{...object};
```

这里不能使用上面的拷贝数组方法，因为当拷贝填充数组之后，填充项 Paint 依然是 Readonly 的值，需要重新创建空填充数组。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills: Paint[] = [];
for (let paint of (layer.fills as Paint[])) {
  if (paint.type === 'SOLID') {
    let newPaint = JSON.parse(JSON.stringify(paint));
    newPaint.color.r = 1 - newPaint.color.r;
    newPaint.color.g = 1 - newPaint.color.g;
    newPaint.color.b = 1 - newPaint.color.b;
    newFills.push(newPaint);
  } else {
    newFills.push(paint);
  }
}
layer.fills = newFills;
```

将 JSON 解析的方法用在填充数组上，填充项 Paint 就不在是 Readonly。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills = JSON.parse(JSON.stringify(layer.fills));
for (let paint of newFills) {
  if (paint.type === 'SOLID') {
    paint.color.r = 1 - paint.color.r;
    paint.color.g = 1 - paint.color.g;
    paint.color.b = 1 - paint.color.b;
  }
}
layer.fills = newFills;
```

或者使用 `array.map()` 创建新的填充数组，然后创建新的填充项 Paint。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).map(paint => {
  if (paint.type === 'SOLID') {
    let newPaint = JSON.parse(JSON.stringify(paint));
    newPaint.color.r = 1 - newPaint.color.r;
    newPaint.color.g = 1 - newPaint.color.g;
    newPaint.color.b = 1 - newPaint.color.b;
    return newPaint;
  } else {
    return paint;
  }
});
```

使用合并对象方式创建新的填充项 Paint，`Object.assign()` 可以使用多个对象做为参数，后面参数的对象的属性会覆盖前面的对象，以此来实现修改某个属性。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).map(paint => {
  if (paint.type === 'SOLID') {
    return Object.assign(
      {},
      paint,
      {
        color: {
          r: 1 - paint.color.r,
          g: 1 - paint.color.g,
          b: 1 - paint.color.b
        }
      }
    );
  } else {
    return paint;
  }
});
```

使用结构赋值方式创建新的填充项 Paint。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).map(paint => {
  if (paint.type === 'SOLID') {
    return {...paint,
      color: {
        r: 1 - paint.color.r,
        g: 1 - paint.color.g,
        b: 1 - paint.color.b
      }
    };
  } else {
    return paint;
  }
});
```

使用条件运算符简化代码。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).map(paint =>
  paint.type === 'SOLID' ?
  Object.assign({}, paint, {color: { r: 1 - paint.color.r, g: 1 - paint.color.g, b: 1 - paint.color.b}}) :
  paint
);
```

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
layer.fills = (layer.fills as Paint[]).map(paint =>
  paint.type === 'SOLID' ?
  {...paint, color: {r: 1 - paint.color.r, g: 1 - paint.color.g, b: 1 - paint.color.b}} :
  paint
);
```

## 通用拷贝

如果在大型项目中使用[官方文档](https://www.figma.com/plugin-docs/editing-properties/)中提供的通用拷贝函数，不需要区分数组还是对象，也可以处理 Readonly 对象相互嵌套的问题。

```typescript
function clone(val) {
  const type = typeof val
  if (val === null) {
    return null
  } else if (type === 'undefined' || type === 'number' ||
             type === 'string' || type === 'boolean') {
    return val
  } else if (type === 'object') {
    if (val instanceof Array) {
      return val.map(x => clone(x))
    } else if (val instanceof Uint8Array) {
      return new Uint8Array(val)
    } else {
      let o = {}
      for (const key in val) {
        o[key] = clone(val[key])
      }
      return o
    }
  }
  throw 'unknown'
}
```

拷贝之后的对象可以直接修改任意属性。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let newFills = clone((layer.fills as Paint[]));
newFills[0].color.r = 1;
newFills[0].opacity = 0.5;
layer.fills = newFills;
```