# 色彩

## 概述

在 Figma plugin API 中只提供了很原始的声明色彩方式，尽管 Scripter API 增加了一些色彩相关函数，但并没有提供实际应用中可能与遇到的例如色彩格式转换或者色彩计算等等，这一章节会详细列出常见的各种色彩相关内容。

通常使用对象直接量方式创建色彩对象，需要注意的是 rgb 的值不是常见的 0 - 255，a 的值不是 0 - 100，而都是 0 - 1。

```typescript
let red = { r: 1, g: 0, b: 0};
let opacityBlack = { r: 0, g: 0, b: 0, a: 0.8 };
```

 Scripter API 可以使用 `Color()`、`RGB()` 和 `RGBA()` 函数创建色彩对象。`Color()` 支持多种参数，

```typescript
let red = Color(1, 0, 0);               // => Color
let opacityBlack = Color(0, 0, 0, 0.8); // => ColorWithAlpha
let green = Color('00FF00');            // => Color 或使用 '0F0'
let gray = Color('CC');                 // => Color
let red2 = RGB(1, 0, 0);                // => Color
let opacityBlack2 = RGBA(0, 0, 0, 0.8); // => ColorWithAlpha
```

Scripter API 还增加了一些色彩常量。

| 常量        | HEX     | Code                   |
| ----------- | ------- | ---------------------- |
| BLACK       | #000000 | Color(0   , 0   , 0)   |
| WHITE       | #FFFFFF | Color(1   , 1   , 1)   |
| GREY / GREY | #808080 | Color(0.5 , 0.5 , 0.5) |
| RED         | #FF0000 | Color(1   , 0   , 0)   |
| GREEN       | #00FF00 | Color(0   , 1   , 0)   |
| BLUE        | #0000FF | Color(0   , 0   , 1)   |
| CYAN        | #00FFFF | Color(0   , 1   , 1)   |
| MAGENTA     | #FF00FF | Color(1   , 0   , 1)   |
| YELLOW      | #FFFF00 | Color(1   , 1   , 0)   |
| ORANGE      | #FF8000 | Color(1   , 0.5 , 0)   |

## 色彩比较

2 个色彩对象不能直接比较，像这样会返回 false。

```typescript
let red1 = { r: 1, g: 0, b: 0};
let red2 = { r: 1, g: 0, b: 0};
print(red1 === red2); // false
```

通常可以将其专为字符串比较，或者逐个属性的值比较。

```typescript
let red1 = { r: 1, g: 0, b: 0};
let red2 = { r: 1, g: 0, b: 0};
print(JSON.stringify(red1) === JSON.stringify(red2)); // true
```

由于转换和计算精度问题，用 0-1 表示的色彩对象和 0-255 表示的色彩对象，尽管最终的 16 进制值一样，但程序可能认为他们颜色不同。还有声明色彩时如果一个包含默认的 `a:1` ，而另一个省略，也会出现程序认为颜色不同。为了避免这种问题，可以统一把色彩的各部分都转到 16 进制值再进行比较。

```typescript
let red1 = Color(0.5, 0, 0, 1); // {"r":0.5,"g":0,"b":0,"a":1}
let red2 = Color('800000');     // {"r":0.5019607843137255,"g":0,"b":0}

print(JSON.stringify(red1) === JSON.stringify(red2)); // false

function isSameColor(color1, color2) :boolean {
  const r = Math.round(color1.r * 255) === Math.round(color2.r * 255);
  const g = Math.round(color1.g * 255) === Math.round(color2.g * 255);
  const b = Math.round(color1.b * 255) === Math.round(color2.b * 255);
  const a = Math.round((color1.a || 1) * 255) === Math.round((color2.a || 1) * 255);
  return r && g && b && a;
}

print(isSameColor(red1, red2)); // true
```

## 色彩格式转换

各种色彩格式的转换可以从网上查找到具体换算公式，这里仅列出一些常见的转换，为了使转换可以适用于 Figma 插件环境，而不仅局限于 Scripter，这里色彩声明方式用的是 Figma plugin API 的对象直接量。

### Color -> HEX(6-8)

HEX 值 6 或 8 位，8 位格式是 CSS4 和 SVG 中的色彩表示方法，后 2 位为透明度。

```typescript
function colorToHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const hex = '#' + Object.values(color).map((component: number) => {
    const comp: string = Math.round(component * 255).toString(16).toUpperCase();
    return (comp.length === 1 ? '0' : '') + comp;
  }).join('');
  return hex;
}
```

```typescript
function colorToHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const hex = '#' + Object.values(color).map((component: number) => {
    return `0${Math.round(component * 255).toString(16).toUpperCase()}`.slice(-2);
  }).join('');
  return hex;
}
```

### Color -> HEX(6)

转为 6位 HEX 值时，直接忽略 Color 的透明度值。

```typescript
function colorToHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const {r, g, b} = color;
  const hex = '#' + [r, g, b].map((component: number) => {
    const comp: string = Math.round(component * 255).toString(16).toUpperCase();
    return (comp.length === 1 ? '0' : '') + comp;
  }).join('');
  return hex;
}
```

```typescript
function colorToHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const int = ((Math.round(color.r * 255) & 0xFF) << 16)
    + ((Math.round(color.g * 255) & 0xFF) << 8)
    + (Math.round(color.b * 255) & 0xFF);
  const string = int.toString(16).toUpperCase();
  return '000000'.substring(string.length) + string;
}
```

### Color -> Android HEX

Android 的 8 位 HEX 值，前 2 位为透明度。

```typescript
function colorToAndroidHex(color :{r: number, g: number, b: number, a?: number}) :string {
  const {r, g, b, a} = color;
  const hex = '#' + [a, r, g, b].map((component: number) => {
    const comp: string = component ? Math.round(component * 255).toString(16).toUpperCase() : '';
    return (comp.length === 1 ? '0' : '') + comp;
  }).join('');
  return hex;
}
```

### Color -> RGB(A)

Color 转 RGB，R/G/B 范围 0-255，A 范围 0-100。

```typescript
function colorToRgb(color :{r: number, g: number, b: number, a?: number}) :{r: number, g: number, b: number, a?: number} {
  const c = {
    r: Math.round(color.r * 255),
    g: Math.round(color.g * 255),
    b: Math.round(color.b * 255)
  };
  if (color.a) {
    c['a'] = Math.round(color.a * 100);
  }
  return c;
}
```

### Color -> CSS rgb() / rgba()

```typescript
function colorToCssRgb(color :{r: number, g: number, b: number, a?: number}) :string {
  const r = Math.round(color.r * 255);
  const g = Math.round(color.g * 255);
  const b = Math.round(color.b * 255);
  if (color.a && color.a !== 0) {
    const a = Math.round(color.a * 100) / 100;
    return `rgba(${r}, ${g}, ${b}, ${a})`;
  } else {
    return `rgb(${r}, ${g}, ${b})`;
  }
}
```

### Color -> NSColor Objective-c

```typescript
function colorToNSColorObjectiveC(color :{r: number, g: number, b: number, a?: number}) :string {
  const r = Math.round(color.r * 1000) / 1000;
  const g = Math.round(color.g * 1000) / 1000;
  const b = Math.round(color.b * 1000) / 1000;
  const a = color.a ? Math.round(color.a * 1000) / 1000 : 1;
  return `[NSColor colorWithCalibratedRed: ${r} green: ${g} blue: ${b} alpha: ${a}]`;
}
```

### Color -> NSColor Swift

```typescript
function colorToNSColorSwift(color :{r: number, g: number, b: number, a?: number}) :string {
  const r = Math.round(color.r * 1000) / 1000;
  const g = Math.round(color.g * 1000) / 1000;
  const b = Math.round(color.b * 1000) / 1000;
  const a = color.a ? Math.round(color.a * 1000) / 1000 : 1;
  return `NSColor(red: ${r}, green: ${g}, blue: ${b}, alpha: ${a})`;
}
```

### Color -> UIColor Objective-c

```typescript
function colorToUIColorObjectiveC(color :{r: number, g: number, b: number, a?: number}) :string {
  const r = Math.round(color.r * 1000) / 1000;
  const g = Math.round(color.g * 1000) / 1000;
  const b = Math.round(color.b * 1000) / 1000;
  const a = color.a ? Math.round(color.a * 1000) / 1000 : 1;
  return `[UIColor colorWithRed: ${r} green: ${g} blue: ${b} alpha: ${a}]`;
}
```

### Color -> UIColor Swift

```typescript
function colorToNSColorObjectiveC(color :{r: number, g: number, b: number, a?: number}) :string {
  const r = Math.round(color.r * 1000) / 1000;
  const g = Math.round(color.g * 1000) / 1000;
  const b = Math.round(color.b * 1000) / 1000;
  const a = color.a ? Math.round(color.a * 1000) / 1000 : 1;
  return `UIColor(red: ${r}, green: ${g}, blue: ${b}, alpha: ${a})`;
}
```

### Color -> HSL(A)

L 范围 0-360，S/L/A 范围 0-100。

```typescript
function colorToHsl(color :{r: number, g: number, b: number, a?: number}) :{h: number, s: number, l: number, a?: number} {
  const {r, g, b, a} = color;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h, s, l = (max + min) / 2;
  if(max === min) {
    h = s = 0;
  } else {
    let d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch(max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }
  }
  h = Math.round(h * 60);
  s = Math.round(s * 100);
  l = Math.round(l * 100);
  if (a) {
    return {h, s, l, a: Math.round(a * 100)};
  } else {
    return {h, s, l};
  }
}
```

### Color -> CSS hsl() / hsla()

H 范围 0-360，S/L 范围 0-100，A 范围 0-1。

```typescript
function colorToCssHsl(color :{r: number, g: number, b: number, a?: number}) :string {
  const {r, g, b, a} = color;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h, s, l = (max + min) / 2;
  if(max === min) {
    h = s = 0;
  } else {
    let d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch(max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }
  }
  h = Math.round(h * 60);
  s = Math.round(s * 100);
  l = Math.round(l * 100);
  if (a) {
    return `hsla(${h}, ${s}%, ${l}%, ${Math.round(a * 100) / 100})`;
  } else {
    return `hsl(${h}, ${s}%, ${l}%)`;
  }
}
```

### Color -> HSV(A) HSB(A)

HSB 有些地方称为 HSV，H 范围 0-360，S/V(B)/A 范围 0-100。

```typescript
function colorToHsv(color :{r: number, g: number, b: number, a?: number}) :{h: number, s: number, v: number, a?: number} {
  const {r, g, b, a} = color;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h, s, v = max;
  let d = max - min;
  s = max === 0 ? 0 : d / max;
  if(max === min) {
    h = 0;
  } else {
    switch(max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }
  }
  h = Math.round(h * 60);
  s = Math.round(s * 100);
  v = Math.round(v * 100);
  if (a) {
    return {h, s, v, a: Math.round(a * 100)};
  } else {
    return {h, s, v};
  }
}
```

### Color -> CMYK

C/M/Y/K 范围 0-100。

```typescript
function colorToCmyk(color :{r: number, g: number, b: number, a?: number}) :{c: number, m: number, y: number, k: number} {
  const {r, g, b} = color;
  let k = Math.min(1 - r, 1 - g, 1 - b);
  let c = (1 - r - k) / (1 - k) || 0;
  let m = (1 - g - k) / (1 - k) || 0;
  let y = (1 - b - k) / (1 - k) || 0;
  [c, m, y, k] = [c, m, y, k].map(val => Math.round(val * 100));
  return {c, m, y, k};
}
```

### Color -> XYZ

X/Y/Z 范围 0-1。

```typescript
function colorToXyz(color :{r: number, g: number, b: number, a?: number}) :{x: number, y: number, z: number} {
  let {r, b, g} = color;
  r = r > 0.04045 ? (((r + 0.055) / 1.055) ** 2.4) : (r / 12.92);
  g = g > 0.04045 ? (((g + 0.055) / 1.055) ** 2.4) : (g / 12.92);
  b = b > 0.04045 ? (((b + 0.055) / 1.055) ** 2.4) : (b / 12.92);
  let x = (r * 0.4124564) + (g * 0.3575761) + (b * 0.1804375);
  let y = (r * 0.2126729) + (g * 0.7151522) + (b * 0.072175);
  let z = (r * 0.0193339) + (g * 0.119192) + (b * 0.9503041);
  return {x, y, z};
}
```

### Color -> Lab

L 范围 0-100，A/B 范围 -128-127。

```typescript
function colorToLab(color :{r: number, g: number, b: number, a?: number}) :{l: number, a: number, b: number} {
  let {r, b, g} = color;
  r = r > 0.04045 ? (((r + 0.055) / 1.055) ** 2.4) : (r / 12.92);
  g = g > 0.04045 ? (((g + 0.055) / 1.055) ** 2.4) : (g / 12.92);
  b = b > 0.04045 ? (((b + 0.055) / 1.055) ** 2.4) : (b / 12.92);
  let x = (r * 0.4124564) + (g * 0.3575761) + (b * 0.1804375);
  let y = (r * 0.2126729) + (g * 0.7151522) + (b * 0.072175);
  let z = (r * 0.0193339) + (g * 0.119192) + (b * 0.9503041);
  x /= 0.950489;
  z /= 1.088840;
  x = x > 0.008856 ? (x ** (1 / 3)) : (7.787037 * x) + (16 / 116);
  y = y > 0.008856 ? (y ** (1 / 3)) : (7.787037 * y) + (16 / 116);
  z = z > 0.008856 ? (z ** (1 / 3)) : (7.787037 * z) + (16 / 116);
  return {l: (116 * y) - 16, a: 500 * (x - y), b: 200 * (y - z)};
}
```


### RGB(A) -> Color

RGB 转 Color，R/G/B 范围 0-255，A 范围 0-100。

```typescript
function rbgToColor(color :{r: number, g: number, b: number, a?: number}) :{r: number, g: number, b: number, a?: number} {
  const c = {
    r: color.r / 255,
    g: color.g / 255,
    b: color.b / 255
  };
  if (color.a) {
    c['a'] = color.a / 100;
  }
  return c;
}
```

### HEX -> Color

Scripter 的 `Color()` 函数可以使用 3 或 6 位数 HEX 值，但不支持 4 或 8 位。

```typescript
function hexToColor(hex :string) :{r: number, g: number, b: number, a?: number} {
  if (hex.length === 1 || hex.length === 2 || hex.length === 5 || hex.length === 7) {
    return {r: 0, g: 0, b: 0};
  }
  if (hex.length === 3 || hex.length === 4) {
    hex = hex.split('').map(char => char.repeat(2)).join();
  }
  const r = parseInt(hex.substr(0, 2), 16) / 255;
  const g = parseInt(hex.substr(2, 2), 16) / 255;
  const b = parseInt(hex.substr(4, 2), 16) / 255;
  if (hex.length === 8) {
    const a = parseInt(hex.substr(6, 2), 16) / 255;
    return {r, g, b, a};
  } else {
    return {r, g, b};
  }
}
```

### HSL -> Color

H 范围 0-360，S/L 范围 0-100，A 范围 0-1。

```typescript
function hslToColor(hsl :{h: number, s: number, l: number, a?: number}) :{r: number, g: number, b: number, a?: number} {
  const h = hsl.h / 360;
  const s = hsl.s / 100;
  const l = hsl.l / 100;
  let r :number, g :number, b :number;
  if (s === 0) {
    r = g = b = l;
  } else {
    let q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    let p = 2 * l - q;
    r = hue2rgb(p, q, h + 1 / 3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1 / 3);
    function hue2rgb(p :number, q :number, t :number) :number {
      if(t < 0) t += 1;
      if(t > 1) t -= 1;
      if(t < 1 / 6) return p + (q - p) * 6 * t;
      if(t < 1 / 2) return q;
      if(t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }
  }
  if (hsl.a) {
    return {r, g, b, a: hsl.a}
  } else {
    return {r, g, b}
  }
}
```

### HSB(A) / HSV(A) -> Color

H 范围 0-360，S/V(B)/A 范围 0-100。

```typescript
function hsvToColor(hsv :{h: number, s: number, v: number, a?: number}) :{r: number, g: number, b: number, a?: number} {
  const h = hsv.h / 60;
  const s = hsv.s / 100;
  const v = hsv.v / 100;
  const i = Math.floor(h);
  const f = h - i;
  const p = v * (1 - s);
  const q = v * (1 - f * s);
  const t = v * (1 - (1 - f) * s);
  const r = [v, q, p, p, t, v][i % 6];
  const g = [t, v, v, q, p, p][i % 6];
  const b = [p, p, t, v, v, q][i % 6];
  if (hsv.a) {
    return {r, g, b: b, a: hsv.a}
  } else {
    return {r, g, b}
  }
}
```

### CMYK -> Color

C/M/Y/K 范围 0-100。

```typescript
function cmykToColor(cmyk :{c: number, m: number, y: number, k: number}) :{r: number, g: number, b: number} {
  const [c, m, y, k] = [cmyk.c, cmyk.m, cmyk.y, cmyk.k].map(val => val / 100);
  const r = 1 - Math.min(1, c * (1 - k) + k);
  const g = 1 - Math.min(1, m * (1 - k) + k);
  const b = 1 - Math.min(1, y * (1 - k) + k);
  return {r, g, b};
}
```

### Lab -> Color

L 范围 0-100，A/B 范围 -128-127。

```typescript
function labToColor(lab :{l: number, a: number, b: number}) :{r: number, g: number, b: number} {
  // CIE lab to CIE XYZ
  let y = (lab.l + 16) / 116;
  let x = lab.a / 500 + y;
  let z = y - lab.b / 200;
  y = y * y * y > 0.008856 ? y * y * y : (y - 16 / 116) / 7.787;
  x = x * x * x > 0.008856 ? x * x * x : (x - 16 / 116) / 7.787;
  z = z * z * z > 0.008856 ? z * z * z : (z - 16 / 116) / 7.787;
  x = x * 95.047;
  y = y * 100;
  z = z * 108.883;
  // CIE XYZ to sRGB
  x = x / 100;
  y = y / 100;
  z = z / 100;
  let r = x * 3.2406 + y * -1.5372 + z * -0.4986;
  let g = x * -0.9689 + y * 1.8758 + z * 0.0415;
  let b = x * 0.0557 + y * -0.2040 + z * 1.0570;
  r = r > 0.0031308 ? 1.055 * Math.pow(r, 1 / 2.4) - 0.055 : 12.92 * r;
  g = g > 0.0031308 ? 1.055 * Math.pow(g, 1 / 2.4) - 0.055 : 12.92 * g;
  b = b > 0.0031308 ? 1.055 * Math.pow(b, 1 / 2.4) - 0.055 : 12.92 * b;
  r = Math.min(Math.max(0, r), 1);
  g = Math.min(Math.max(0, g), 1);
  b = Math.min(Math.max(0, b), 1);
  return {r, g, b};
}
```

## 常用色彩算法

### 反色

```typescript
function inverse(color :{r: number, g: number, b: number, a?: number}) :{r: number, g: number, b: number, a: number} {
  let {r, b, g, a} = color;
  [r, g, b, a] = [r, b, g, a].map(val => val ? 1 - val : 1);
  return {r, b, g, a};
}
```

### 灰度

将色彩专为灰色。

```typescript
function grayscale(color :{r: number, g: number, b: number, a?: number}) :{r: number, g: number, b: number, a?: number} {
  let {r, b, g, a} = color;
  r = g = b = 0.2989 * r + 0.5870 * b + 0.1140 * b;
  return {r, b, g, a: a || 1};
}
```

### 明度

明度(Brightness)，返回 0-1 数值，W3C 的算法。

```typescript
function getBrightness(color :{r: number, g: number, b: number, a?: number}) :number {
  return (color.r * 299 + color.g * 587 + color.b * 114) / 1000;
}
```

HSP 色彩模式的算法。

```typescript
function getBrightness(color :{r: number, g: number, b: number, a?: number}) :number {
  return Math.sqrt(color.r ** 2 * 0.241 + color.g ** 2 * 0.691 + color.b ** 2 * 0.068);
}
```

### 光亮度

光亮度(Luminance) ，返回 0-1 数值，W3C 的算法。

```typescript
function getLuminance(color :{r: number, g: number, b: number, a?: number}) :number {
  let {r, b, g} = color;
  if (r <= 0.03928) {r /= 12.92} else {r = Math.pow(((r + 0.055) / 1.055), 2.4)}
  if (g <= 0.03928) {g /= 12.92} else {g = Math.pow(((g + 0.055) / 1.055), 2.4)}
  if (b <= 0.03928) {b /= 12.92} else {b = Math.pow(((b + 0.055) / 1.055), 2.4)}
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
```

### 色彩相似度

返回的数值越小表示色彩越相似。

```typescript
function distance(color1 :{r: number, g: number, b: number, a?: number}, color2 :{r: number, g: number, b: number, a?: number}) :number {
  const [lab1, lab2] = [color1, color2].map(color => {
    let {r, b, g} = color;
    r = r > 0.04045 ? (((r + 0.055) / 1.055) ** 2.4) : (r / 12.92);
    g = g > 0.04045 ? (((g + 0.055) / 1.055) ** 2.4) : (g / 12.92);
    b = b > 0.04045 ? (((b + 0.055) / 1.055) ** 2.4) : (b / 12.92);
    let x = (r * 0.4124564) + (g * 0.3575761) + (b * 0.1804375);
    let y = (r * 0.2126729) + (g * 0.7151522) + (b * 0.072175);
    let z = (r * 0.0193339) + (g * 0.119192) + (b * 0.9503041);
    x /= 0.950489;
    z /= 1.088840;
    x = x > 0.008856 ? (x ** (1 / 3)) : (7.787037 * x) + (16 / 116);
    y = y > 0.008856 ? (y ** (1 / 3)) : (7.787037 * y) + (16 / 116);
    z = z > 0.008856 ? (z ** (1 / 3)) : (7.787037 * z) + (16 / 116);
    return {l: (116 * y) - 16, a: 500 * (x - y), b: 200 * (y - z)};
  });
  return Math.sqrt(Math.pow((lab2.l - lab1.l), 2) + Math.pow((lab2.a - lab1.a), 2) + Math.pow((lab2.b - lab1.b), 2));
}
```

