# 填充





#### 示例：查找并替换颜色

```typescript
const findColor = 'E02424';
const replaceColor = '00FF00';

visit(currentPage, (n :BaseNode) => {
  if (isShape(n) || isFrame(n)) {
    if (n.fills === figma.mixed) {
      if (isText(n)) {
        n.characters.split('').forEach((val, i) => {
          const rangeFills = n.getRangeFills(i, i + 1);
          if (rangeFills !== figma.mixed) {
            const rangeFillsRelpace = rangeFills.map(paint => {
              if (paint.type === 'SOLID') {
                if (colorToHex(paint.color) === findColor) {
                  return {...paint, color: hexToColor(replaceColor)};
                }
              }
              return paint;
            });
            n.setRangeFills(i, i + 1, rangeFillsRelpace);
          }
        });
      }
    } else {
      n.fills = n.fills.map(paint => {
        if (paint.type === 'SOLID') {
          if (colorToHex(paint.color) === findColor) {
            return {...paint, color: hexToColor(replaceColor)};
          }
        }
        return paint;
      });
    }
  }
});

function colorToHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const {r, g, b} = color;
  const hex = [r, g, b].map((component: number) => {
    const comp: string = Math.round(component * 255).toString(16).toUpperCase();
    return (comp.length === 1 ? '0' : '') + comp;
  }).join('');
  return hex;
}

function hexToColor(hex :string) :{r: number, g: number, b: number} {
  const r = parseInt(hex.substr(0, 2), 16) / 255;
  const g = parseInt(hex.substr(2, 2), 16) / 255;
  const b = parseInt(hex.substr(4, 2), 16) / 255;
  return {r, g, b};
}
```

