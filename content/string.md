# 字符串

使用单引号（**'**）或双引号（**"**）来表示字符串类型，引号包含相同的引号，内部的引号需要使用 `\` 转义。

```typescript
let a: string = 'abc';
let b: string = "abcd";
let c: string = 'I\'m a "cat".'; // 或 "I'm a \"cat\"."
```

对于太长的字符串为了便于阅读，有 2 种方式将器拆分为较短的几段，字符串拼接和续行符。

```typescript
let poem: string = '桃之夭夭，灼灼其华。之子于归，宜其室家。' +
  '桃之夭夭，有蕡其实。之子于归，宜其家室。' +
  '桃之夭夭，其叶蓁蓁。之子于归，宜其家人。';

let poem: string = '桃之夭夭，灼灼其华。之子于归，宜其室家。\
桃之夭夭，有蕡其实。之子于归，宜其家室。\
桃之夭夭，其叶蓁蓁。之子于归，宜其家人。';
```

在字符串中添加换行。

```typescript
let poem: string = '桃之夭夭，灼灼其华。之子于归，宜其室家。\n' +
  '桃之夭夭，有蕡其实。之子于归，宜其家室。\n' +
  '桃之夭夭，其叶蓁蓁。之子于归，宜其家人。';

let poem: string = '桃之夭夭，灼灼其华。之子于归，宜其室家。\n\
桃之夭夭，有蕡其实。之子于归，宜其家室。\n\
桃之夭夭，其叶蓁蓁。之子于归，宜其家人。';
```

模板字符串使用反引号 (**`**) 来代替普通字符串中的用双引号和单引号允许使用 `${}` 嵌入表达式。

```typescript
const messageZh: string = `选中 ${figma.currentPage.selection.length} 个图层。`;
print(messageZh);

// 英文需要考虑单词复数形式
const messageEn: string = `Selected ${figma.currentPage.selection.length} layer${figma.currentPage.selection.length > 1 ? 's' : ''}。`;
print(messageEn);
```

模板字符串也可以用来表示多行。

```typescript
let poem: string = `桃之夭夭，灼灼其华。之子于归，宜其室家。
桃之夭夭，有蕡其实。之子于归，宜其家室。
桃之夭夭，其叶蓁蓁。之子于归，宜其家人。`;
```