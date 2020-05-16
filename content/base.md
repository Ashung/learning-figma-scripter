# 基础知识

## 概述

Scripter 使用 TypeScript 作为默认编程语言，TypeScript 是一种由微软开发的跨平台的编程语言。TypeScript 可以看作是对 JavaScript 的一种补充或扩展，它是兼容 JavaScript 的，所以在 Scripter 中直接使用 JavaScript 也是可以运行的，但由于编辑器的自动检查功能，会出现一些错误提示 （红色波浪线）。

由于 Scripter 中的 TypeScript 被局限在这个插件内，无法使用第三方库，还有本教程是针对设计师的简单入门，所以也不会介绍 TypeScript 语言中那些难理解的复杂特性，基础的 TypeScript 对于 Scripter 插件的日常使用已经足够了。

学习编程最高效的方法不是阅读了多少教程和书籍，而是直接动手，不断的训练，尽量跟着下面的教程中代码一字一句的打出来，不要复制粘贴。

在对这些基础的 TypeScript 和 JavaScript 有了一定了解之后，并且有一点经验之后，可以再阅读以下文档学习更深入的知识。

- [MDN JavaScript 参考](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference)
- [现代 JavaScript 教程](https://zh.javascript.info/)
- [TypeScript 中文文档](https://www.tslang.cn/docs/home.html)
- [深入理解 TypeScript](https://jkchao.github.io/typescript-book-chinese/)

## 代码格式

代码格式就像是设计源文件里的图层结构，尽管图层很乱，但不妨碍结果，代码格式也是这样，它不会影响运行结果，但本教程会按照统一的格式，以下会详细说明各种格式。

## 注释

注释不会被程序运行，它是通常是用解释代码的作用、来源等等，有些编辑器会利用特殊格式的注释当真某种功能，编辑器中通常都将注释显示为灰色。

单行注释，以 `//` 开始到当前行结束的内容都会被程序忽略，注释和取消注释的快捷键为 ⌘ /。

```typescript
// 单行注释，用来解释下方的代码
const selectedLayers; // 单行注释，用来解释左侧的代码
```

多行注释，以 `/*` 开始，至 `*/` 结束，之间的内容都会被程序忽略，块级注释和取消块级注释的快捷键为 ⇧⌥ A。

```typescript
/*
多行注释
*/
const selectedLayers; /* 不建议这样的多行注释
const currentPage; */
```

养成好的注释习惯，可以在当你过了很久再看自己代码的时候，还可以回忆当时思考过程，注释也可以帮助别人读懂你的代码。另外注释也不一定是用来解释代码的，如果代码条例清晰，命名准确是不需要解释的，注释通常也用来为代码添加文档、版权等等额外信息。

 `TODO` 注释用来表示待办事项，通用编辑器通常会汇集所有的这种注释，但在 Scripter 中可以用搜索来快速定位待办事项。

```typescript
// TODO: 待办事项
```

当代码过于长的时候，这种情况可以刻意增大用于给代码分区块的注释区域，当显示代码略缩图 Minimap 时，可以清楚看到注释的位置，您也可以试试带有各种图案的注释。

```typescript
////////////////////////////////////////////////////////////
// 夸大的注释
////////////////////////////////////////////////////////////
```

## 输出

输出用于显示某个对象或变量的信息，或者运行结果，在 Scripter 中使用 `print()` 可以把信息输出到编辑器界面上，但这个在循环中只会输出最后一项，也以用 `console.log()`把信息输出到浏览器控制台上。

打开 JavaScript 控制台的方法，不同浏览器会略有差别。Chrome 浏览器，在菜单 “视图 - 开发者 - JavaScript 控制台” 下打开，其他浏览器有的需要打开“开发者工具”，然后选择“Console”标签。Figma 桌面应用在菜单下的 “Plugins - More - Development - Open Console” 项打开。

在打开 JavaScript 控制台的情况下，在 Scripter 插件内运行下面的代码。

```typescript
print(1);
console.log(1+1);
```

`print()` 也会在控制台输出结果， `console.log()` 的性能更高，而且可支持多个参数和替换字符串。

```typescript
console.log('选中', figma.currentPage.selection.length, '个图层。');
console.log('选中 %d 个图层。', figma.currentPage.selection.length);
```

## 变量声明

变量在编程中用来保存数据，在 TypeScript 中变量名是区分大小写的，变量的命名必须遵循以下规则。

- 变量名由字母、数字、下划线、$ 符合组成。
- 变量名不可以是 TypeScript 的关键字或保留字，就是在 TypeScript 有特殊用途的单词，这些单词在编辑器中会以加粗显示。
- 变量名不能以数字开头。

另外还需要遵循一些常规，例如使用名词和驼峰式命名，即首字母小写之后每个单词的首字母大写。

在 TypeScirpt 中通常使用 `let` 或 `const` 来声明变量，也可以使用早期的 `var`，这里统一使用新的  `let` 和 `const`。

`let` 关键字声明的变量，可以被重新赋予新的值（值可改），而 `const` 关键字声明的变量，不允许被重新赋值（值不可改）。声明可改变量时也可以不为其赋值，行后的分号可以省略。

```typescript
let layerName = 'Group';
layerName = 'Frame';

const colorName = 'Red';
colorName = 'Green'; // 出错提示 colorName is read-only

// 声明变量时不赋值，省略分号
let name
name = 'abc' 
```

连续声明变量可以使用如下的简写方式，行尾使用逗号而不是分号，第二个变量起省略 `let` 或 `const` 关键字，按等号对齐可以更方便查看。

```typescript
let r = 1,
    g = 0,
    b = 0.5;
/*
等同以下方式
let r = 1;
let g = 0;
let b = 0.5;
*/
```

## 基本数据类型

在 TypeScript 中变量声明时可以定义变量的数据类型，TypeScript 中的数据类型包括基本类型和对象。基本类型包括：数字、字符串、布尔值、数组、元组、枚举、空和未定义。

### 任意类型

声明变量时不指定数据类型，表示变量是任意类型，也可以指定多个类型。当为变量赋值时未指定类型，程序会自动推断变量的类型，当无法推断类型时，默认为 `any` 类型。

```typescript
let a; // 任意类型
let b: any; // 任意类型
```

### 数字

数字 `number` 包括整数、小数、二进制、八进制、十六进制。二进制的表示使用 `0b` 或 `0B` 后跟数字 `0` 或 `1` 数字的组合；八进制的表示使用 `0o` 或 `0O` 后跟数字 `0` 至 `7` 数字的组合；十六进制的表示使用 `0x` 或 `0X` 后跟数字 `0` 至 `9` 和 `a` 至 `f` 的组合。

```typescript
let a: number = 123467890;    // 十进制
let b: number = 0o1234670;    // 八进制
let c: number = 0xff;         // 十六进制
let d: number = 0b1011;       // 二进制
```

### 字符串

字符串 `string` 使用单引号（**'**）或双引号（**"**）来表示字符串类型。

```typescript
let a: string = 'abc';
let b: string = "abcd";
```

### 布尔值

布尔值 `boolean` 表示逻辑的真 true 或假 false、对或错、是或非。

```typescript
// 是否只选中一个图层
let selectedOneLayer = figma.currentPage.selection.length === 1;
// 是否只选中一个文本图层
let isTextLayer: boolean = selectedOneLayer && figma.currentPage.selection[0].type === 'TEXT';
```

### 数组和元组

数组是有序的元素序列。元组是一个已知元素数量和类型的数组。

```typescript
let list: number[] = [1, 2, 3];
let list: Array<number> = [1, 2, 3];
```

### 空和未定义

空 `null` 表示对象值缺失，对象不存在。未定义 `undefined` 表示变量的值未被定义、未被赋值。

### 联合类型

将变量设置多种类型，赋值时可以根据设置的类型来赋值。

```typescript
let a: number | string;
let layer = figma.getNodeById('1:1'); // BaseNode | null
```

## 对象

包括常用的数组、函数、日期、数学、JSON、正则表达式等等 JavaScript 标准内置对象，另外 Figma 和 Scripter 还引入一些特定对象，这些会在之后的内容中详细介绍。


## 类型推论

类型推论 (Type Inference)，或者称为类型推导、型別推断，在没有明确指出类型的时候，TypeScript 能根据一些简单的规则推出变量的类型。

```typescript
let count = 2; // 自动推断为 number
let pageName = figma.currentPage.name; // 自动推断为 string
```

## 类型断言

类型断言 (Type Assertion) 用来手动指定一个值的类型，即允许变量从一种类型更改为另一种类型。

```typescript
<InstanceNode>layer // <类型>值
layer as InstanceNode// 值 as 类型
```
