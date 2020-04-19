# 组件







```typescript
const iconJsonUrl = 'https://raw.githubusercontent.com/iconify/collections-json/master/json/ant-design.json';
const iconJson = await fetchJson(iconJsonUrl);
const icons = iconJson.icons;
const size = 24;
const color = '#000000';

let i = 0;
const col = 10;
const gap = 24;

for (const icon in icons) {
  const path = icons[icon]['body'];
  const svg = `<svg width="${size}" height="${size}" viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">${path.replace('currentColor', color)}</svg>`

  const layer = figma.createNodeFromSvg(svg);
  const component = figma.createComponent();
  component.x = i % col * (size + gap);
  component.y = Math.floor(i / 10) * (size + gap);
  component.resize(size, size);
  component.name = 'Ant Desicon Icon / ' + icon;
  for(let child of layer.children) {
    component.appendChild(child);
  }
  layer.remove();

  i++;
}
```

