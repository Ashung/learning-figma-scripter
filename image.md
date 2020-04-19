# 位图

## 概述

在 Figma 中没有真正意义上的位图类型图层，其本质是一个形状上的位图填充 `ImagePaint`。

## 选择位图

#### 选择当前页面所有位图

```typescript
let images = await find(n => isImage(n) && n);
setSelection(images);
```

```typescript
let images = await find(n => {
  return isImage(n) && n
  }, {
    includeHidden: true
});
setSelection(images);
```

## 修改位图

#### 修改位图填充的缩放模式。

// "FILL" | "FIT" | "CROP" | "TILE"

```typescript
for (let shape of await find(selection(), n => isImage(n) && n)) {
  shape.fills = shape.fills.map(p => {
    return isImage(p) ? {...p, scaleMode: 'FIT'} : p;
  });
}
```

```typescript
for (const layer of figma.currentPage.selection) {
  const fills = JSON.parse(JSON.stringify((layer as GeometryMixin).fills));
  for (const paint of fills) {
    if (paint.type === 'IMAGE') {
      paint.scaleMode = 'FIT';
    }
  }
  (layer as GeometryMixin).fills = fills;
}
```