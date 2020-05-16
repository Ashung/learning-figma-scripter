# 图层选择与查找

## 概述

统一修改选中图层的某些属性，按类型或某种条件查找图层然后统一修改某些属性是非常常用的操作。选择符合某些条件图层，在实际中反而比较少用，因为在脚本中修改图层属性可以直接进行，属性修改相比选中图层要复杂许多，会在下一篇详细介绍，此处的脚本都仅是选中图层、显示信息或数量而已。

## 图层选择

### 选中图层信息

`selection()`  或 `figma.currentPage.selection` 返回当前页面选中的图层数组，通过索引值可以返回选中图层中的某一个图层，例如 `selection(0)`  或 `figma.currentPage.selection[0]`  返回选中图层的第一个，即是图层列表最下方的图层。

#### 示例：统计选中图层数

统计选中图层数在实际工作中非常有用， `print()` 将信息统计显示在编辑器内。

```typescript
print(selection().length);
print(figma.currentPage.selection.length);
```

也可以将信息统计显示在警告框内。

```typescript
alert(`选中了 ${selection().length} 个图层。`);
```

### 操作选中图层

通过遍历 `selection()`  或 `figma.currentPage.selection` 返回的数组操作选中图层。

#### 示例：在选中图层的图层名前增加序号

```typescript
selection().forEach((n, i) => {
  n.name = (i + 1) + ' ' + n.name;
});
```

### 选择图层

通过 Figma Plugin API  的 `figma.currentPage.selection` 或 Scripter API 的 `setSelection()`，`setSelection()` 参数可以是 `null`、`undefined`、图层或数组，参数是  `null`、`undefined` 时取消所有选择。不能通过重复 `setSelection()` 选择多个图层，必须先获取图层再转为数组。

```typescript
figma.currentPage.selection = ReadonlyArray<SceneNode>;
```

```typescript
setSelection<T extends BaseNode|null|undefined|ReadonlyArray<BaseNode|null|undefined>>(n :T) :T
```

#### 示例：选择选中图层的子级

Figma Plugin API 的 `figma.currentPage.selection` 值必须是数组。 

```typescript
let childs: any[] = [];
for (let n of figma.currentPage.selection) {
  if ((n as ChildrenMixin).children) {
    childs = childs.concat((n as ChildrenMixin).children);
  }
}
figma.currentPage.selection = childs;
```

全选即是选择当前页面的所有子级。

```typescript
figma.currentPage.selection = figma.currentPage.children;
```

Scripter API 方式。

```typescript
setSelection(currentPage.children);
```

#### 示例：按索引选择

选择当前页面图层列表中最下方的图层。

```typescript
setSelection(currentPage.children[0]);
```

选择当前页面图层列表中最下方的图层。

```typescript
setSelection(currentPage.children[currentPage.children.length - 1]);
// setSelection(currentPage.children.slice().pop());
// setSelection(currentPage.children.slice().reverse()[0]);
```

## 图层查找

### Figma Plugin API 查找方法

在 Figma Plugin API 中，DocumentNode 或任何继承 ChildrenMixin 的节点都可以使用以下方法查找图层。

`findChildren()` 遍历元素的第一层子级，返回符合条件的节点的数组，也可以使用 `node.children.filter(callback)` 实现类似功能。遍历第一层子级的顺序为从图层列表中的从下到上。

```typescript
findChildren(callback?: (node: SceneNode) => boolean): SceneNode[]
```

`findChild()` 遍历元素的第一层子级，返回第一个符合条件的节点，也可以使用 `node.children.find(callback)` 实现类似功能。

```typescript
findChild(callback: (node: SceneNode) => boolean): SceneNode | null
```

`findAll()` 遍历元素的所有子级，返回符合条件的节点的数组。遍历所有子级的顺序为从图层列表中的从外到内。

```typescript
findAll(callback?: (node: SceneNode) => boolean): SceneNode[]
```

`findOne()` 遍历元素的所有子级，返回第一个符合条件的节点。

```typescript
findOne(callback: (node: SceneNode) => boolean): SceneNode | null
```

### Scripter API 查找函数

`findOne()` 遍历第一个参数元素的所有子级，返回满足第二参数条件的第一个节点，为找到满足条件节点时返回 `null`。

```typescript
findOne<R extends SceneNode>(scope :BaseNode, p :(n :PageNode|SceneNode) => R|false) :R|null
```

```typescript
findOne(scope :DocumentNode, p :(n :PageNode|SceneNode) => boolean|undefined) :PageNode|SceneNode|null
```

```typescript
findOne(scope :PageNode|SceneNode, p :(n :SceneNode) => boolean|undefined) :SceneNode|null
```

`findOne()` 没有 node 参数时，遍历当前页面的所有子级。

```typescript
findOne<R extends SceneNode>(p :(n :SceneNode) => R|false) :R|null
```

```typescript
findOne(p :(n :SceneNode) => boolean|undefined) :SceneNode|null
```

`find()` 遍历节点的所有子级，返回所有符合条件的节点。当 node 参数为数组时，遍历数组元素本身及其子级。

```typescript
find<R extends BaseNode>(node :ContainerNode|ReadonlyArray<BaseNode>, predicate :(n :BaseNode) => R|false, options? :FindOptions) :Promise<R[]>
```

```typescript
find(node :ContainerNode|ReadonlyArray<BaseNode>, predicate :(n :BaseNode) => boolean|undefined, options? :FindOptions) :Promise<BaseNode[]>
```

没有 node 参数时，遍历当前页面的所有子级。

```typescript
find<R extends BaseNode>(predicate :(n :BaseNode) => R|false, options? :FindOptions) :Promise<R[]>
```

```typescript
find(predicate :(n :BaseNode) => boolean|undefined, options? :FindOptions) :Promise<BaseNode[]>
```

可选的 `options` 参数可以设定是否包含隐藏节点，默认为 false，忽略隐藏图层。

```typescript
FindOptions { includeHidden? :boolean }
```

`visit()` 遍历 node 参数的所有子级，每个子级都调用 visitor 函数，如果 visitor 函数 return false，那么节点的子级就会被忽略。

```typescript
visit(node :ContainerNode|ReadonlyArray<ContainerNode>, visitor :(n :BaseNode) => any) :Promise<void>
```

### 在当前页面中查找

使用 Figma plugin API  可以用 PageNode 的 `findAll()`、`findChild()`、`findChildren()` 和 `findOne()` 4 个方法。Scripter 的 `findOne()` 和 `find()` 都是遍历整个图层树形的，这个运行速度要比只遍历第一层级要慢很多，特别是在图层非常多的情况下，在实际的情况下，需要考虑选择哪一种速度更快。

#### 示例：在当前页面第一级的图层中，删除非 Frame 的图层

将代码中的 `FRAME` 改为 `COMPONENT` 即可删除非组件图层。

```typescript
figma.currentPage.findChildren(n => n.type !== 'FRAME').forEach(n => {
  n.remove();
});
```

```typescript
for (let n of figma.currentPage.findChildren(n => n.type !== 'FRAME')) {
  n.remove();
};
```

#### 示例：删除当前页面的隐藏图层

如果仅将在图层列表中关闭显示或将图层透明设为 0 的图层定义为隐藏图层，获取这些图层就比较简单，但实际中类似空的 Frame，无任何填充描边特效的形状图层，是否要删除或者有特殊用处。

用 Figma plugin API，删除当前页中关闭显示或透明度为 0 的图层。有些情况父级和子级都设置了关闭显示或透明，`findAll()` 的遍历顺序是的外到内，所以会先删除父级，当删除子级的时候程序就会因找不到图层而出错，或者因多人协作，在运行脚本过程中图层已被其他人删除，也会产生错误，所以在删除前需要判断图层是否已被删除。

```typescript
figma.currentPage.findAll(n => n.visible === false || (n as BlendMixin).opacity === 0).forEach(n => {
  if (!n.removed) {
    n.remove();
  }
});
```

Instance 内的图层是无法删除的，所以上面的代码在 Instance 内有隐藏图层的时候会出错。当存在 Instance 时，需要判断图层是否在 Instance 内。

```typescript
figma.currentPage.findAll(n => {
  return n.visible === false || (n as BlendMixin).opacity === 0;
}).forEach(n => {
  if (!inInstance(n) && !n.removed) {
    n.remove();
  }
});

function inInstance(node): boolean {
  let parent = node.parent;
  while(parent.type !== 'PAGE') {
    if (parent.type === 'INSTANCE') {
      return true;
    }
    parent = parent.parent;
  }
  return false;
}
```

或者重新写一个遍历当前页面的函数，过滤掉 Instance 类型。

```typescript
traverse(figma.currentPage, n => {
  if (n.visible === false || (n as BlendMixin).opacity === 0) {
    if (!n.removed) {
      n.remove();
    }
  }
});

function traverse(node, callback) {
  callback(node);
  if (("children" in node) && node.type !== "INSTANCE") {
    for (const child of node.children) {
      traverse(child, callback)
    }
  }
}
```

使用 Scripter API 的 `visit()` 可以在让遇到父级满足条件时就忽略子级，所以如果文件没有其他人可编辑，可以不需要判断图层是否可以删除。

```typescript
visit(currentPage, (n) => {
  if (n.type === 'INSTANCE') {
    return false;
  } else {
    if ((n as SceneNode).visible === false || (n as BlendMixin).opacity === 0) {
      n.remove();
    }
  }
});
```

### 在选中图层中查找

在选中图层中查找，可能存在 2 种情况，只处理选中的图层与处理选择图层及其子级。

只处理选中的图层就比较简单直接遍历数组。

```typescript
for (let node of figma.currentPage.selection) {
  // if () {}
}
```

或者使用 Array 的 `filter()` 和 `find()` 方法， `filter()` 返回符合条件的数组，`find()` 返回首个符合条件的元素。

```typescript
let selectedCompontents = figma.currentPage.selection.filter(n => n.type === 'COMPONENT');
print(selectedCompontents.map(n => n.name));
```

```typescript
let selectedCompontent = figma.currentPage.selection.find(n => n.type === 'COMPONENT');
print(selectedCompontent ? selectedCompontent.name : 'No layer');
```

Figma plugin API 的 `findAll()`、`findChild()`、`findChildren()` 和 `findOne()` 4 个方法和 Scripter 的 `findOne()` 都是只遍历子级的，不包含本身。处理选择图层及其子级情况，使用 Figma plugin API 就比较复杂。

```typescript
for (let node of figma.currentPage.selection) {
  console.log(node.type, node.name);
  // Do something
  if ((node as ChildrenMixin).children) {
    for (let child of (node as ChildrenMixin).findAll(n => true)) {
      console.log(child.type, child.name);
      // Do something
    }
  }
}
```

Scripter 的 `find()` 在参数为数组时会遍历数组元素本身及其子级，上面的代码可以简化为。

```typescript
let nodes = await find(selection(), n => true);
nodes.forEach(n => {
  console.log(n.type, n.name);
  // Do something
});
```

### 在文档中查找

!> 如果文件非常大，查找整个文档可能导致运行速度非常慢。另外对非当前页面进行的操作，用户无法直观的察觉到，可能导致失误发生。一般情况尽量不要对整个文档进行操作，如果需要务必在运行脚本之前保存一个版本，在运行脚本之后，检查结果是否符合自己的预期。

使用 Figma plugin API 查找整个文档需要先遍历页面，在按照页面查找方式处理。使用 Scripter API 的 `find()` 则可以用 documentNode 作为参数。

#### 示例：删除文档中的隐藏图层

Figma plugin API 的方式。

```typescript
traverse(figma.root, n => {
  if (n.visible === false || (n as BlendMixin).opacity === 0) {
    if (!n.removed) {
      n.remove();
    }
  }
});

function traverse(node, callback) {
  callback(node);
  if (("children" in node) && node.type !== "INSTANCE") {
    for (const child of node.children) {
      traverse(child, callback)
    }
  }
}
```

使用 Scripter API 的 `find()` 遍历文档，默认不包含 `node.visible === false` 的隐藏图层，需要增加 `findOption` 参数。

```typescript
let document = figma.root as ContainerNode;
let nodes = await find(document, n => isHidden(n), { includeHidden: true });
nodes.forEach(n => {
  if (!inInstance(n) && !n.removed) {
    n.remove();
  }
});

function isHidden(n: BaseNode): boolean {
  return (n as SceneNode).visible === false || (n as BlendMixin).opacity === 0;
}

function inInstance(node): boolean {
  let parent = node.parent;
  while(parent.type !== 'PAGE') {
    if (parent.type === 'INSTANCE') {
      return true;
    }
    parent = parent.parent;
  }
  return false;
}
```

或者先遍历页面，在使用 Scripter API 的 `visit()` 。

```typescript
for (let page of figma.root.children) {
  visit(currentPage, (n) => {
    if (n.type === 'INSTANCE') {
      return false;
    } else {
      if ((n as SceneNode).visible === false || (n as BlendMixin).opacity === 0) {
        n.remove();
      }
    }
  });
}
```

### 按索引查找

在某些固定图层结构，按索引直接取得图层是非常高效的，例如从其他软件或文件导入，可能在每个组内最下方都有一个无用的图层，要将其删除可以通过 `ChildrenMixin.children[0]` 得到最下方图层。

```typescript
for (let node of figma.currentPage.selection) {
  if ((node as ChildrenMixin).children) {
    (node as ChildrenMixin).children[0].remove();
  }
}
```

### 按图层名查找

在遍历数组的代码内使用 `if (node.name === 'xxx') {}` 的判断，或者直接用数组的 `fliter()` 或 `find()` 方法，例如  `Array.filter(node => node.name === 'xxx')` 或 `Array.find(node => node.name === 'xxx')`。

使用正则表达式可以进行更高级图层名查找。

#### 示例：删除图层名称后的数字

删除当前页面中图层名称后的数字。

```typescript
let nodes = await find(n => /\s\d+$/.test(n.name), { includeHidden: true });
nodes.forEach(n => {
  n.name = n.name.replace(/\s\d+$/, '');
});
```

### 按类型查找

在 Figma plugin API 中使用 `node.type` 来获取节点类型，Scripter API 增加一些简化的函数，在 Scripter 运行期间，如果图层在 Group 和 Frame 之间切换，需要重新运行 Scripter 。

下表为 Figma plugin API 和 Scripter API 中关于类型判断的对比。

| Figma plugin API 类 | node.type | Scripter API | 说明 |
| ------------ | ---- | ---- | ------------ |
| DocumentNode | DOCUMENT | isDocument() | 文档 |
| PageNode     | PAGE | isPage() | 页 |
| SliceNode    | SLICE | isSlice() | 切片 |
| FrameNode    | FRAME | isFrame() | Frame |
| GroupNode | GROUP | isGroup() | 组 |
| ComponentNode | COMPONENT | isComponent() | 组件 |
| InstanceNode | INSTANCE | isInstance() | 组件实例 |
| BooleanOperationNode | BOOLEAN_OPERATION | isBooleanOperation() | 布尔运行 |
| VectorNode | VECTOR | isVector() | 矢量 |
| StarNode | STAR | isStar() | 星形 |
| LineNode | LINE | isLine() | 线条 |
| EllipseNode | ELLIPSE | isEllipse() | 圆形 |
| PolygonNode | POLYGON | isPolygon() | 多边形 |
| RectangleNode | RECTANGLE | isRectangle() isRect() | 矩形 |
| TextNode | TEXT | isText() | 文本 |
|  |  | isSceneNode() | 包括表内的 SliceNode 至 TextNode |
|  |  | isContainerNode() | 可以有子级的图层 |
|  |  | isShape() | TextNode 也被算进 shape |
|  |  | isImage() | 如果图层列表图标是图片类型，则返回 true。 |

#### 示例：选择当前页面所有位图

```typescript
let images = await find(n => {
  return isImage(n) && n
  }, {
    includeHidden: true
});
setSelection(images);
```

### 按属性查找

可以从 Figma plugin API 和 Scripter API 的声明文件中，找到每个节点类型支持的属性，如果要按某个节点类型特有属性查找图层，需要先判断是否为某个节点类型。

例如，以下代码将选中当前页面中尺寸不是 24x24 的所有切片。

```typescript
let nodes = await find(n => {
  return isSlice(n) && n.width !== 24 && n.height !== 24;
}, { includeHidden: true });
setSelection(nodes);
```

## 定位图层

定位图层是在画布上居中显示图层，使用 `ViewportAPI.scrollAndZoomIntoView(nodes: ReadonlyArray<BaseNode>)` 方法定位图层。

按图层 ID 查找定位。

```typescript
let layer = figma.getNodeById('9:1');

if (layer && layer.type !== 'DOCUMENT' && layer.type !== 'PAGE') {
  figma.currentPage = getPage(layer);
  figma.currentPage.selection = [layer as SceneNode];
  figma.viewport.scrollAndZoomIntoView(figma.currentPage.selection);
}

function getPage(node: BaseNode): PageNode {
  if (node.type !== 'PAGE') {
    return getPage(node.parent as BaseNode);
  } else {
    return node;
  }
}
```

按图层名查找定位。

```typescript
let layer = figma.root.children.map(page => {
  return page.findOne(node => {
    return node && node.name === 'Polygon';
  })
}).find(node => node !== null);

if (layer) {
  figma.currentPage = getPage(layer);
  figma.currentPage.selection = [layer as SceneNode];
  figma.viewport.scrollAndZoomIntoView(figma.currentPage.selection);
}

function getPage(node: BaseNode): PageNode {
  if (node.type !== 'PAGE') {
    return getPage(node.parent as BaseNode);
  } else {
    return node;
  }
}
```

