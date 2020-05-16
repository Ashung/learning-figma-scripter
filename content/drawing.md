# 绘图

## Paint 对象

Paint 对象用于图层的填充 Fills 和描边 Strokes，以及 PaintStyle 样式中，包括 3 种类型 单色 SolidPaint、渐变色GradientPaint 和位图 ImagePaint。这里只讲单色和渐变色，位图类型在另外的位图部分单独讲述。

### SolidPaint

```typescript
// Figma Plugin API Typings
interface SolidPaint {
  readonly type: "SOLID"
  readonly color: RGB
  readonly visible?: boolean
  readonly opacity?: number
  readonly blendMode?: BlendMode
}
```

创建 SolidPiant，type 和 color 属性是必需项。

```typescript
let paint: SolidPaint = {
  type: 'SOLID',
  color: { r: 1, g: 0, b: 0 },
  // visible: boolean 是否可见，可选，默认为 true
  // opacity: number 透明度，可选，默认为 1
  // blendMode: BlendMode 混合默认，可选，默认为 PASS_THROUGH，可用值请查看声明文件
};
```

属性 color 值类型为 RGB，如果遇到 RGBA 的色彩则需转为 RGB，alpha 值转为  opacity 属性值。

```typescript
let redOpacity: RGBA = { r: 1, g: 0, b: 0, a: 0.5 };
let paint: SolidPaint = {
  type: 'SOLID',
  color: {r: redOpacity.r, g: redOpacity.g, b: redOpacity.b},
  opacity: redOpacity.a
};
```

或者使用 Scripter 中的方法实现 RGB 与 RGBA 之间互转。

```typescript
Color.withAlpha(a: number) // RGB -> RGBA
ColorWithAlpha.withoutAlpha() // RGBA -> RGB
```

在 Scripter 中可以通过以下几种方式快速创建单色 SolidPaint 对象，带有 alpha 的颜色，会自动转为 paint 的 opacity 属性。

```typescript
Color(1, 0, 0).paint
Color(1, 0, 0, 0.5).paint // alpha 自动转为 paint 的 opacity 属性
Color('FF0000').paint
RED.paint // 可用色彩名称见上一章 “色彩”
RGB(1, 0, 0).paint
RGBA(1, 0, 0, 0.5).paint // alpha 自动转为 paint 的 opacity 属性
```

这种方式创建的 SolidPaint 对象，不可直接修改 readonly 的 `visible`, `opacity` 和 `blendMode` 等等，需要拷贝对象后再修改。

```typescript
let paint: SolidPaint = {...Color(1, 0, 0).paint, opacity: 0.5};
```

### GradientPaint

```typescript
// Figma Plugin API Typings
interface GradientPaint {
  readonly type: "GRADIENT_LINEAR" | "GRADIENT_RADIAL" | "GRADIENT_ANGULAR" | "GRADIENT_DIAMOND"
  readonly gradientTransform: Transform
  readonly gradientStops: ReadonlyArray<ColorStop>
  readonly visible?: boolean
  readonly opacity?: number
  readonly blendMode?: BlendMode
}

type Transform = [
	[number, number, number],
	[number, number, number]
]

interface ColorStop {
	readonly position: number
	readonly color: RGBA
}
```

创建 SolidPiant，type、gradientTransform 和 gradientStops 属性是必需项。ColorStop.position 值范围从 0-1，ColorStop.position 的值必须为 RGBA。

```typescript
let paint: GradientPaint = {
  type: 'GRADIENT_LINEAR',
  gradientTransform: [[1, 0, 0], [0, 1, 0]],
  gradientStops: [
    {position: 0, color: {r:1, g:1, b:1, a:1}},
    {position: 1, color: {r:0, g:0, b:0, a:1}}
  ]
};
```

下表列出不同类型渐变常用几种角度的 `Transform` 值。

<table>
<thead>
<tr>
<th width="80">Gradient</th>
<th>Transform</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANDSURBVHgBhVfbcRsxDAQ49yF9OekgHXicClKCW0gH7iQluAWng3SQlOBUIP1oJM1IQsA7gloueQ5nOMfjA1gsQOBOxdtut/tyuVxeT6fTo/fP3iX38/lsx+NR4xnzZU3wHbp515W1ubust8Ph8OLjv5O/ZOW/r9frg6pK7rn50/JDoOU5XZqYWfS6D8fRYM7ijJ9/nqbp22azeUo++OETD6EjbywH53FWmscBaJG37IkzZU5YeQGtMMT1T2706+SD50BWBGtYmxWH8BgzQ8Sa/K8hCJf3mFBAmcTNfNgQJJwxw4O0FkN6ziwkEi4BCCw2AJIHwYrCGbRKCHTdPwCvCQ42QkhxuESodUxEgA7mWPm8KZWBDUAoP9H/HIwa12MZVxBwRqWlf26pKKjC0XoIurgNAvQ3oDpqinvI6nodZXGlJaDDaGNVXjY39IWFt9ttGIDAkA3A1WeK64aoSR4GY3VVsMQUGFJUgpb143gKYRj1AsmF54pSQ0YoWHVghMBNbQClsCgEhV/B90L0VwZAcKxXyiGmLFIpsTXvmwB5zWyYWsNqYgTzBJ5BIILrpLjuS4hWmsQljVIAibejWYdWwdX7ujy7QE9A1YeJ/H7FWxCRaAbXMapYnB8GZbJ7icRChPkAs1u4CfOEUi3AlM4K+0RUNqNVzSaDihh7CltIbWO5rLfuSiZQUuu29WW3cQG7IyIcmDDyPbe61lVDVI4JCgKSU6uAjABSQ191mKvrWhpMVn/DdVuRIzbIhJ0bBRjhloBS/OBo/BxCUMkoq4UBcv9GhOkuFywAIshY4MhitI7cIoNmxETnunxuitwOEJtsBsoUryrFQtQKZPrDvFLkLnmgHG4+IsD3ZlSwYg8lGWEj1vyOLa4hzhlSjcpB8drVaq4eyOX4sQbAiBoBCjkgrf10M8iIChlQUkrICGfIFgBQWgMELVX6ZANX1M8sBs520Xv9KN0PNhtGu95LNV5ZBMT1YK311dD7H9UuZrqcjTXAqD4UQDX7IRgC1fzauYt+Jv8x/e6Te7hmPewVd/A4FCIYvf8TNDXF+84BvKTtdvvuIJ584Y2SUiBu/gtG9WGMubIQ9SEs3/vrL/8p/uq/5+//ACzidbKa0xIxAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[1, 0, 0], [0, 1, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMQSURBVHgBfVfLlRMxEJSWvrNksFdOPI5OgSzIYANwDoSwZ26QgY/cIASIYMzNfp5x05qnFqVSa/c9rccaqT/V1SU5J/tbluVJRF62bftwu93ereuayrDvat+zPauN7PP1XbJ3iefK2rLH39e59lw+bXy73+/Px+PxT67Of9rLt3VhdufFad3oAbRA3LkH6c59DyYBe32+rDlfr9eP5lu+oHPYsD/XqDOggUYTIdOh5HNuAwIun48G/ktBQDlaz9o38ajr0GhCVKJS+Roai8zqWp55kyOCkAL05TlHnHA0a3Lq6+z5UcCZUqQh3BAklsUdRMlgqTwYX5OFaqVILl/sAdJmDNJtRN3SSFgcQrn2eSFYMyKA5EHDwPzdaEVugJ9K2IJArkhENIK9qz1lPiNp0wOykz1zD0gCcjXDwI0ZrNFeZL0SnwZiCwmFBnWNHA16wcF5vdEhaIoHk+U1kYFsOoUj9UtgkDsF53UdOykJQ4QRQttwrTMSMVA5tKdcVuwYYWYzXOsaHzzrRIrRqTtGpFCIik+httEg0ml38DoSH2+59kl7/ncBwTo4pmyYqE1gAiUdkOCAZY1bq+t/hIxOTHbUMo+cEvx7wALOO8bDpijyvMXnfJqVEMkJSOWuC7gjmJzkmDNPBLmTeMga5lTQETsHvcd3GTOoxpqwBNqA6xOVdBeiroVQfOrmAdIgkw7qYH64L3hQQjVHSJnxHdtnBrf4mG5IMRmFxIdbJ2pHhXXhTRmTQbiRZ25bUIBIRpUg7M5zajEMqjsTiFOJO0rc2CtS24xjFtyWqIBU0syOkZQsxagD3G54W9Kgp5XLhO8o+FY+4RoDbBE3ctBaTs7uOOd2o9twzwFEAH9WBZkPCKzjhXM4QSec2G0/2L9zwGQFSBXucbrFp+SeIZz9EaJcpj3QEsAvcMQE5HLg8TqQFiBWDxaP4YJu/XHqgX5/uFwunysK3EaDuk24wl3h5el4UgNHKV5s7vnN6XQ6Hw6Hrzb5ZOM9OERFRJ1vt54tuJbjz3BAD5Xxr40fNj5Z8r//AaXUdnVsx8aOAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[0.5, 0.5, 0], [-0.5, 0.5, 0.5]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAL8SURBVHgBjVftbRsxDCXjg+F/vW7gDYp2go7QFbpBN8kIWaGdJBmhhQdw+ss2YFuVLiL99ES5EXCQ7iRSj48f0qnkdjgcttM0Panqp5TSR6ktv+fXpNbLO9p71l6v15/r9fpHXvtH9/v9drVaPT88PHwwHVlBo4iB5CZlDW9YxiZf30vnsogzf3s9n8+fp8vl8pgf39wE3uTfhJgFshKtjSxv1lXZ0s+5f9LdbpeQvoiBRlu1yoDhd7Oc11d93lfZMt5Px+NRIiW4kAAiU813BlQbumCRkxsrswNAH1XFnV/15lQbR+5iY/SGqXHj0k2n08k2tQUOyAKOLEEqw4CT1gVdAKO+wgDSp62sCmyqI6X2WaiRGzsGyvcp1wAlyiSgin2sBDLaOA2Maty2xAAHEfm6ye0AIMuii+5mSxmXGMAoTUEkKwARCjq9EztuBHsGx4UBjOYw/ykTZABUDCBbGRjgrcRAh4qElKOf8/qeO9gNqNuygKnr0owDjbJCOeeppozScple6gAFTbgpCqMl3EYMRYXOs4DyVKINjBGiXIQKVAAC9Xc63QVQWXBzRIYxgSXNUXO5C1zq54ABMQa6E9EWaVs7MTbwcEGr7l1GeM6DUKPAa/gFa+t7Y7mtNWoN/IhZm+tcECBODALn61xjIRrABpEOXeoABJiBQZQYcDJiJ7IQ9Pk9goN1OQ2ZwrrQ/VyFnEpBbXHjY7phCvWWOsD+x4WR8hSAkwBLoiBGRlzOs4ACbVlnFsA8XqeQjeZEQpem/h7YjD0LAksVLPHNBxZzTXC3ya08N3GicCERQI2+xiCM72Yx5cYepl4DHvU1Z0EQOPauo1SkutAUMmYGgt1V+VkwyGWuihEDQ3Aox6SZTAHwmsczTxoTVO34YiIEogNArWOnAHjJ/dfIKtc+tja0EMFEGQYe/aXzPG/zT+JznpwJYYINdJCK/7PS9aDVVe8+/5N+WT5sNptt/mV+zM83FIyDfTwJ1t121ObSUIZ/c/+S/8i/Z/Z//wOP5uRJrGSUNgAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[0, 1, 0], [-1, 0, 1]]</code>
</td>
</tr>
<tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANpSURBVHgBhZcxdtRADIalrFNslXCDtFR53CA1VbgBR6BMmS4lR0hNB0ego4MjwAkWyrwkO2gcS/4kezfzntfj8Yz169cvzayKtbu7uwu73Q/DcGnXG7ukX6enp22z2aj1m13q44cum9/vvubY3K92fdput3+Gm5ubi4eHh582cKaq4s36TftPa+LjPlbnvdw0+n3N9K7f/H3zMbuurXu12+3eDfbw+fHx8Wyc2Zr6gulqbsfHp4+3aa7QYB/rfYL2ee7MtLbfz83p+8GMXxtl7hC9DoPTgmCDnoEJqf3Cnj/PE0Uuh6enJ2GrHrBNIQhGAKhNBpTf8Xd9HKEK4NY/7wwIeYGHQRkWKEAyLAxXZcG/46CpER2en58F6D1IYZgCdCDwLgmuvbTEgmQRMmTj3M4AnE8KTyIjcrCyKkayUL4XunJNdAa0UCYeNKJF7On5UihYMxkjsEWWjRpoc344OnWEgriB7ob0YqpW8Sbg/p5h61ng3jYpqeXerrCw8KSCoxMlNIkRDwFZT2JjSJCiaxVPqreVtfq+Nw+Bl9LUnyhUJwL1IRgoYFr1kobJhK9jIWK+xzyiPUBlotSB1HrCDCLbYx2oqGSFwlqUXmnUSDC1lpbBAISYjPoiLzyy3ANSwVoBIUzZoosxC0JosqQ8xRRzGsqyP7t+WEOUDq1UwwDA4LbiTnpk2aZxMKYrqSfFkdCHh4Co9EjcGdN0XqD4HKgss6Qy0VIIvHhUT6VQXoXEZ9SOhUN1HhkQGi/xXuwV6IcAWzm6SQ7dai3obdwNZRZL853PKa4VsoQngQbFyRA0E4cUtxm7oS+c9oa0adAAEKWSXSgOrwEmnR2DAc8Cd6Ufv3U+XKSSvJZiBOVr3MiRbJAEQBBHNFWc6QSHjxJvqTVB5tAcZMnvvhkl6ia6eKBoAJSFkU9JpF/3+32KOUUp0EAgqkUC3qbqJ1l8sWO2fAaU/g8JdYYijmNZ1IGTk5P4MsLR+EyjCEf6uM4VqIo4/a9QbMd/7cU5F1CAEFY1JADGNEsANGcUDzbjvQP4ZS+uZL3k0kACUQtTy4eaBBreKzVg7dvGqP9uDx/tYUtxac7plPfuhRssbT4QLhvX70x/HzY9BAbii41d2Lu3dYF/C9+MBHgFiGAyi90/u/2wv/Lvb29vf/8H5U2cQu8Cb7gAAAAASUVORK5CYII=" alt=""/>
</td>
<td>
<code>[[-0.5, 0.5, 0.5], [-0.5,-0.5, 1]]</code>
</td>
</tr>
<tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANYSURBVHgBdVfbbRwxDCTlhR+AAV86cAeGU0FKcAvpwJ2khLTgdJAOkhKcCuI/G/CD5u5qtKPRngBhTxIlkkNypHPLdjgcrqdp+nl+fn6T/Ut2m/vZ2Vnk17PHxcWF17llLcdGcjwXOfb59zyPL2Rrf7i8vLzPtX9T6r9+f3//kwZcRYRRi1KKZ1sHuZY9fG0YL0vZIbf8hjzm6p75a7Xfvb6+fnt+fr4tp6enPz4+Pq7qBl/3Lgd7zgeU4iAY0qzMZf4NxWSk4zzIzuN07jCjPqWSO2xgD8hyowMgp7JDg42pSJfamfm9KbwBm0iJjgOG8doMTF1rZxEKQQ4Zy2U7FDooRJmT0s30DYkuXLKXnQLskEdIljlGoEsunMzhNmkt83ZkCE04Rum0zZdqFeBhT5yVWB/v0GQ0SjIy0MRB2bIa4BxTOE7JB88aIkhOfHeQgcdDlcBz/C7NHescakjUSTdCINbGxgYnMNZq7Q+hUwRafe94ziEIstBJViEI2jeERRGZ6DAkYWhImAGVLyip4H2XzORIl2eMgE52UCPWMIYRYLFj4UAYqsxQBRN7aR3i64Bqtn3hCZLMt/vCKfbdHEeB0FuTUKAdmtZ59JRsWloUZ2ce4ISEDBO1lmJHqRSKkDVlUFagCoekZANaNVAlhDAH34xGIcAdMcBvQmAmrfGA1C5n94BM9aRBK+tdzDlc7D0qppCSFre8olmIs9qlMhqrCRLh/R3QeY05ZsIOHrZYk5MRwW/J+NYhpufa9mpyrgKm38YBGkeBN/YUaFiIC4YzCuMThLfTDu8fFsz1SrPmQs883jOwMNnMj9CQGmeLie0aACGUy+UpXncPEchP2Gf9S8fYe+tftu2RSV52L19V6MefeMZVoEJOme41OvoWHGgZypmkor+UhhzYSyz+NiOYEkieUehKT9kS8poDpocBAa5/O16KqGlXBKy/sIZ7YDHARkh9z1I2kopl7623F86jlTAb8KTe19P4vm9a6ACTrOYQDJXBaNGeJQR/tc4ZBYxj43muGPWwe5iwp6wUc0n5v8rJycn3nHjSOCvstkPV+hthU/b0/bfA/zTgvry8vDymEbc58WAjrbZq3KrS+JFqe7XudCkZvQGqcXPIf7+9vX3Nv+ePn3WxkL7pRWJ7AAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[-1, 0, 1], [0, -1, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMHSURBVHgBfZfdkdswDIRFifbYT3E6SAeZpKN0cE14xm8p4Vq4dJAOkhIuFZw7YCiboD4sYXtGlvgLYLELUWmqv8Ph8GW3270uy/I15/y5XtN61Xap/cnu6J9qe7K29JX6nNZnzrPn9b7f79/meX45n8//0mq8TvhTBz6tE2Go1Cs9c8TG1nlt8z4Og32trWnta0rpW23nnzRuG65RYFHCRrdN2/hEg22ei9aCsLGG0Dp+qvfXdDqdSgD5bWIQTY/KNmUq2jp3aSoEvY/8bHFwmfeGSHcc/d2wpq+hUYDKKUsuI+gK4CMi3LSnS6O1VJnxtY2AEh2wCY5cbNtioOWUwTV2WQDVKZK6qyUTPm6Iyf0OdApIGpFRUegBSlBTDmQ1AVqXHmW01gYah1I0qN7fUNlIRAOqDHFSJdnXCOsLUcwR4clSjVxSUaB1wmnPlGhSfkgqNt4Jmx3ZmBJEvBEoznnSlDREQjSy5vIB/GoswVESKzLS+6SgFUNgIB5l5hjr8xjxJTHayHD2hehOQhgokVEYd+MkXeBcr3zkSR5l6TwtUcSAzfEFTB/eGTRK8i1jyR+lxTrOVCxSzwND0ZjK0juCjclWV/MlTdZXUEw4PkS6bKVZX9f9XeBUILp1737ReXlEPiKi0jMF3OYrOyUFZsTVfDjoyJXlRdT2SY8URAQUBXLClVjVMo0yjVEtiJzJy1gFzTPH+JBAQbmVCJ0iwKHNQZZYHh4f6Hsi+UgqGjQjkhYimZwMRYKU3EganI7EmBab6ICqaup1IEkO6XFkfCg6ArVb+wDJ+10Y22WHxQ5ufnwsvlpSDQMJF1+U+sdLzlIsclwPNOeuFIO05IiTG4lHZ/Ju/IRK+srEmMt5BPsyniUG4jnH698138/nU6Db/kweqOzydup1xSgg3YDiXP/+Ik/uzUUD+UlpxVgvyeaQng3YV9u/5vqB+KM2roxiF3/5FoHwdtfjN3JNyEvgyEfte5kvl8t7+0p9Y/6hZf0uoMSGYoUIC5WEIK71+Xe9fz8ej+//AWpY6ImSEdE2AAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[-0.5, -0.5, 1], [0.5, -0.5, 0.5]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAL5SURBVHgBhVjBjRsxDKSABWwDBs75+5EOgqSClJAW0kE6uRKuhaSSXAlJBb572Q/bOkknaocjSreAYS9XIodDDnfXQdKx3W4/3263p/v9/iWE8EnWI6ZPiOlI9iCTIy2RuqTskfnxe1mWX5fL5X/IwdPJ32R8qE4CBq/OCwAE4gX0gIIt/yy2ev6S4n5d9vv9Y7rwABfUoQYUZqF60tMAwTyiAn6Dz0P6PIXj8RgRcA2WvWNmihwTEydb8So1sZ+WVAIZBPE2MCMrGhHx0scS1ISwRw7LZrMRZBZ8mF7AjPU3ODeA6AiAjxs0LLvdTpEWdNlJ3aCNJ9XmFRhr0sDWaOzH7NfzzADS5zVU4GC6XwNyMwJLWH9XRZkBjzekXc89MDO9NzWBLUDyBVBpQmwudjzStmY+akBQksgAaF6TAbRpJ5ZSoc0oPTMvZGUIAY/YsU2YAHRDZjLNZLSGA7D2R0ypDLlOH2XTGKCp2A2oyYwo7osMefJ5YJys3NlAcZsPHFog72gm4QBEuy6OzkHvDM7o3yACWTYAMp9mZg2BiIMR3JoTFYYsqgpM9jRAIgRGhtpaWUesDK6Nbt3vg6gyEMHIQAJSh0GVXchaL1jaYB/ZQlMB1DFQs0Uay53+FSSCUbsCJUANfOsBXAg10gwbCCo5gjAZgh9OqK0rDGATIl1QCgZl2BGqqe6lfRESMqrJcwClh5QGcoTNBUmuwCCBrtZaHgaYewCR6t1KBo6FpO0/gVDWCJbVUUpAAwgl1wUFFjBLlKdQYDOsKJkmQ1dq6nyWMTaaWHlWHJ0CDBhsQhkE7IIH/4nZPF1H5wbq7fcAeJJiEKbD4/qEgwlw/bv9BgBp35UTZsvOhXqD5cZyVuAZwIu8v6UgEH5ZQSmhByEQIr1UkcaOhQzgOX1/H2Ql5HQmP8McgnZKV2zpZfhPOJ1O+nJ6cAaPsCOnIVliXsM1PwD4dL1evxXD+XzOIB7Tzx8jRxxsIsvuhoT2dP6aPs/p74CfaQr/ewNOIDkTh4TIdAAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[0, -1, 1], [1, 0, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAANLSURBVHgBjVfBcSIxEBzBQsHLXAaXgcsZOARScAZ+8uTJzyFcCneR2CH4IuDuRxVQupHQzLZaWs6qWnaRRqOZnp5eCKJjt9t919uPy+XyqNc3veR8Pove4/V6Dfqc72n+C1fU63+2P/V6PZ1Ov4f9fp8Of9dDHmKMAiOG25A0X+7JIOTFYktzeU/lZFyP4H+r1/NqtXoa9ONNo3lIs2Vz9pO+wo48bybxNuwsPzPNKVJCibidxVTum4T6oGMLGUUydARKUA1CNCc81TfxuccUgEV/d3N5jpZNgcD2GljNaWlBz3AEKfDNMJ/PMaNepLEcmOdmsxmum9PQ2c9+MAhDPAyLxcII5kTBciDZPKKxxgEyFalL6Ptk5BOu5e+pBBEiNVah8x7ZcjzkNK/3ULiDgKQScMRNJtQNeBiWhAeWB2IJ3mXJJpOw1FJKVhVNrc6YmSFgz4VHU4k0a8XvDQHlgNU2Gbv4oK05M+IUOtg+exYwChw0+sPnwVrEsqdnzwT50VO8OrnAYjTZqrkNAXo3KDU2+Hvsd3aDSFWHgGp6YMAZ7wILu2khqduwkVjMGOeAU74ONhXaGECeKDQVkGAPgINkOwwEuIBIVQkkf1mIEFZ0hhus7aQVm9jJ0oUNkmts0jAOiLGaMolwsEhfzz1wIbHpdFSDoOsAZMxlcB6AjXeO1RuhlenRcMw4EAD66kABiCl7fwFhF2B2AlzAcuL7YbILwHGUWsMrIZFOndEH+xwfQ4WAo4D1L5ubEnRsMLt8C9R3EDDajVJswgOZe50RIVLIxqGlR7rh5YKA8pn5bQjGzmhrmQ4BbbMHNNG6owrVsPszd4HXBUSHBQg7BEtj+yMEi78tGpRsNF2A8GLGAr+QegIVxx+ud8sWWIiAhJ4N9Hfgw4ErgSEPo9I1atkhZZgKoNEDDILFSdpuidCq2LpdhaxeRty3tImzrZwjNzr27NdRSAH8kdu/FGQ8iktkFYR2YoSEoK66KdRid2tDHR/65RkXATI/gN8BSMYJ5OwQ5A//6vqVAnjRiXdd2zDkmInU7wQ/mPVCOuqI6ECZjvo/8nVYr9efx+PxablcvuniloSHRQrvPWXELmD07J3yV20+9A/xy+Fw+PwHHQdYZGrCtzwAAAAASUVORK5CYII=" alt=""/>
</td>
<td>
<code>[[0.5, -0.5, 0.5], [0.5, 0.5, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAT1SURBVHgBXZeJkSRHCEWTmZr70HgguSBZIA9k6oYskDyQJ9qNibmPzuXR/+eyXRF0XdnwgQ9kjbE/fkv5J+X/lGmJiF0/Hx0dzePj43l6ejrPzs5Kzs/P63xyclLvcs2u6zjQ5+svKb9iOGT8v5Rf6gGr5hz7E/+JgeE0EBjZti1Shp6PuT/qP+/v7/Pz8zPe3t7Gx8fH2O12YykZdVn/41Hef0v5nYsv+fAvvfTCugREejdSAq9TyjiepnhNGUIwiiSQ8fr6uoR3Prpjef43FBIfRjvS0Ly4uIiUIRAjAYyMQr3De68FvAFgnAhg+OXlpc5PT0/1zmsbmK9bMz6krwxdXl6WAMAgiAIASAdpcQQy7FMAogNATxoHbHDO5yEehEzebc1wQcMQhq+urkIgKhJJNqdiKA1LGSFN4+S/DBuA16Ws9AKiRSJWBFACyfA2jSPz+vo6fC+2BwBRjOAZihCFvwxg/Pn5GeNFYNaZW0SKKMnhAlBQWISn8r4ikACIQHDfolAcoBpQjhKUwn6TD+MG6TRhnFSxjkiZC5vzgWLnO2U6BYAgGlwngALhagC0OFARcOjhiXpCuES1plJFlJKgFZVN3q9yw8BBJCoVJqWiMEXEKiuUp/dh5ivn9c7R6RViAdjGIpS5u9lLAakUYPjm5maqKkJccG5JwXTNwyNFJsyNg/IMlzRRqBSQU8LKQwGpRQaiFIQiUpUBaNLAYfaLeOFnGLWksSn9oVLeVwphtDLXOAtd94rIqgYTE55ARPJI+Ak9jsh42HAaqd7RDbdmFgWAnJnZejn8J6FeJDUIUsFzIkhoWc+1Qg7Rig+aITZa5MSOS3QB4KxpVy8tLieBqPQAJDlR6eEg9BwuQ3TYIZ81PxZBxZO5uU5jf0x3Rk87A5RUsyIyGL+9vV3zA48N1iWqUlwGra89G0dtOKxB5JkwfsxwN445NLFHGyFe11u6u6v7jDrm7MOoGpEm2fRE6/PdNexxa2ar3c77+/sCQ66JAO/c6fwft2rJ0suR5zCAZYRriIQSda9ieTeck6084xpF1DY8oNTgAGtFxvAmxfoEbsqxudkzDHmctsZBbmE0Xhab1XxqjSei6pzRayDDUUGnd0gNhOdBbG0ns4yrY62e7REMadxkWt2HGxHPHh8fqYoC7O6IAzqv/uAt2+ZGov5c+aTUFNa1B4TRnnwo0MBZXc+DiAgkCDYgtRPiHl1yyHOgbNYsIAxtSNRCNRA3jp88J1UopEuqItY0dBQEYnJOCW3NfF6R8DiuLZUXUOOa57MZn971gFzgwsAgk3I9nX/4QDp6JAwAAfQCgBt9I6FmsfacVAYgRcoVHW3Lh973CIb4UBVjABZsrT7QmkS99BZKjSW8kzGbtdcrbrhhaezONnIJ/zIMEPOCe3WjWAB8oIBF3nL3nQzhZSqqIjxMVuPyBFTZhrgQJqWjAVfUIcdPALRvq50NuZPxacVMQ2+3xI/VueGAG5h3RkQC4zgEmIeHh4qgbZlXAOAT6c6fTRx40VpvlU//OvKAailwmkZPlQkJEJxo23jPkPrho/RPDZFoGalJRsiZ/dof9B1xB+AWO1oaVv0TnR7lZuvv9XGaL+/8wh+nVg4pPYY7AV2GBtBnh/eCfXL23PNZlvd/+B4QfDL3T+jdwX1d0xEFZudP9P55zqf8gSx9+sz/qqhjc3wH3xv+0YEiMYYAAAAASUVORK5CYII=" alt=""/>
</td>
<td>
<code>[[0, -1, 1], [1, 0, 0]]、[[1, 0, 0], [0, 1, 0]]、[[0, 1, 0], [-1, 0, 1]]、[[-1, 0, 1], [0, -1, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAS1SURBVHgBbVc7bmRHDGxKrS8EeJwpVOpo4Rs4duQr+AZ7Ex/BsTP7Fs7WR/BmynYWEPSXuCxOVaNmsA9ovDdvuvkpkkW+GHVdX1/fRMSfp6enH2r9eHZ2Nuo+Tk5Osu4x58x6juPj44F1dHTUS1dmrvX6+ppvb29R9/Hy8tLr+fl5rcfHR7z7++Hh4eN2u/0cm83mphR+Oj8//6HWqBVQXu9aeSluQ8qINqQMaENwwYjcXQHlpbifoVQGlNKsezw9PWWtwRVlwLbuP8+Li4s/SlErr+eA4lq4w5AkEnsolOIsxIIohLyH57WGew/D4Xnt7f11DGdxbgPUZwn9jZ631zQCIUihQRRgBAQqBG2Eh0DKzfve72GL3aUzHyaUYZkRQGLoPcPRghAKCINX8gTr/f09a+EeMgDKYXjFPOE998PgBGrcv1kGEPpWTkNCqCgXmJDtCXIBQikMYUDyDcUf+xBvQY99O7CylWMvzk15COEygoh0CIQOQqIwqBo8BBCKCkDCwQiDPaWc90EDulqQAxAsj8PCEQxF0ICVD0hIKC8lXgGdgCo3GUAbBz1PDxP2Twk+WKoEhSSFEg1QNbhHC3ouxXxVCZTDc8ipvUAqpzxSpjMk4aGwfFgExRzosiL8IQPkPWFvxdyzFvVh/3S26zgz4VZukCOUH9jbHCEPAa0yH2Gx9wsZ4wehuCttMlsznaGxFxaRk/MF9ouO5R293wuLKV4lrDD1b2b0ym4zZPUCVojzRSOg+gb8ZLuGXAlJ5UmFe4qxF+enGEovFD95Q0MGK8UJq/+DBSo7wE7F6YiobFm6S08jj3C5ETig335QiCA8qg6EBxcIh543EVGBGpcUpmQaJee0Wt2j18NFozpZmYTj8vJSmd4VcOBpEFVVhJrRktd31KfaumpW5IF31r0aPhAKKVhXaJ/28D5IUmG/02cIXJMZm9bVFruJPNg4VlaTbvP+/r6NQQKq1JCAxvXD5AyXK3ac+kNK8KzD4myRjNirFAaTryVx4OhSkyHqjuJ8yeNKOpbz8CUEqK4hGGWEBaXKeihlzFWGTUKYdDT1qCtqPHOnDNWYglUb8QcPq77jgF4bQmb76u0aQDjztcGailSWhuSQrilFfJmcYqR4zYBSxsFT2R7OhFAG78uIhQS7Y4dLqPjgCgSWpYqxT7NeOgoVQmOcv9cNpRRDqClX4i49QmFycGyh5r2Yca/82HQUkrBeL4/SQhEIB5YhsYbVNTnhAex2OEBqeLQxajfBGJ/7sEEEQglLpSlD3Ag3ZGp6ca724ZHCWznYT8MGG9GqabVkdT5VBNFIrxAYBiPbaTdg0SMRcDLSvCf4jWKTQ+lKZMUbSi0cacm5jJucXL3MwhNOgtUR1cWEgAYShcGTmsm4csIrg19KAQS2JWzj33r0an3r+deRBhGhxRAoR4Z/FyrWUqxQMCdWCP4rQb8o2Yz/WyC8hlBViNrsgQGL3dgrUkwKT0XVUq5wlMx/Zgn4vf74VDI23hFV1zCAxNOzgIYVXM6M3+sd9mWcB1SN+5c6+vH47u5ue3V19VcdvClBP1nnUpMK/+yyGC/u8E9wlRwhHyzJsPdfa/1byn+9vb39/xsooH6o+P8aoAAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[-0.5, -0.5, 1], [0.5, -0.5, 0.5]]、[[0.5, -0.5, 0.5], [0.5, 0.5, 0]]、[[0.5, 0.5, 0], [-0.5, 0.5, 0.5]]、[[-0.5, 0.5, 0.5], [-0.5, -0.5, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARISURBVHgBdVfbURwxENQcCwX8gCm++HICFIUjcQpkQCYOAULAEeAM7BBwABT88H6Mp4dpXa84b5VOrz11z0xrpLUWz9d43t7ezt7f34/c/UvUrYpHsZiLYUed41pr4X+ibbLGpxJrXUzTdHpwcPDXAB4cfsfETk1a1QleQJ1I1QqcgEVA2zMjsB7Go2q17u3j4+PxYm1t7YeZ7URpi8UiKvOoGxpBzNGXNuok1+oBYXYLqGmhETVn4oXd9fX1MyB+BzDBg1DiFBGrh+RatRMbP8WpkYQAE2jWJ0m04zmasJgYlO0CyMXZR13e6N4RYFdvDGR6CDBfDuR7u0pAF0x8sIx5l7YV82wj/pjjwvy/Ck4Eme+wXwQsCWAAVgFM2DsB8U7NWemDHjKyHQSnIVARqkZyfFLRUSTqAWiC1nNhFWZ5oI3AK4rpziLpiQtzgFJQ69CvUFl5w0QLq4Sm+cBGEhgv4j6Fhflyia0rXsnQSpIUD3TtMD9g/vX1VUPShrjPysStV+7pCuWWAxAWLllkSFAgQAmbr0hMY0JqGqouQoKjU9tuRqLENgsJQOClUfUAfHl5MXhAvMB3nKCSB1IDiSEamImtwjFTP/oB4KUfj7YFMMDRThK0vgxqKj5ue3qgD1CQ5er+JyYjJQFQtOHq5+fn9vT0hJLW15kxy3ySoJiQsp0ERla6t7tYpikXjtr4n4eHh3T1/f19FnihdGASSs2ATXZNSkg9MKbXRiAZS8Ftbm7a9vZ2jl9fX3sUWq4KL412y6mxvib61EDf+yq+UmbjgcQw4bWNjQ07PDxsl5eXtr+/D8/k9g3STk01SZb8v8wtCWBBGZwpXnLDxx8CCOBbW1u+t7dnNzc3SRIewVwcsV2weqiRzXDAGTVgBdZZS8k8gbmKP0NgAeYQ4N3dXXouxjMflDf6+UKDhFDXxSRxdj3z6XosgAJwWhgeQM1zwiE+EMHaGAcJrIuiazL+ElJjCPrgaDkeLARwlgLPd5iCQUL1xITDkxRr4t0BIzXQLS8hNt6QOFfWdC+UZV1hkgW7lJgH6AWSEM3l3zMVMz6VXp1Jh4XuJJHSRL+o8BzAPGp6kG6Wbdm3ZBc173fFUmPmJbxGDaDmnVG81l3O069ORGNGZS7QHVCp/oPAeOGke8t93WLuBk3JhU5P5Ht13je2SYAaYVvzQJO6J5tRCwI+Sygud0q9LyA7qlgltzgFqbtASTQFFBGZbiNbfibkvQDx5+JMNDxhoR2ScLlbrvKACSnXPglpSpWDhjsi67rE9ExY4aEH+r0Dvr5dEX8vt9OdvIC47mHVgC+f2R1Ra0yO1/VYd/FHgJoNX0FDf/aJpg/DIMe6j6Byv/Cqf+Lb8CQAbhfz78JZHig3frJe23rh4Hegzy8hLp7B3E144XRxfn5+FS8cB9DFf84CaqBrcGm0f/qsGwD5HUAyeG6j/yve+XZycnL1Dz582JVnx3iLAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[0, -1, 1], [1, 0, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARySURBVHgBdVdLTh0xEHQ/BoTYhHCCXABFyQEI3CAbDpA1m2z4iP+SXY6QKyQ3yA2SIyQrdiQSQvxxupouU2MeI1nPY3tc1dUf+1nxZ3V19c39/f3Xh4eHt7XW1/5bslVv5nPxizHvcy76bDI2dS2a780137z/2aH/TADunZ9m9sHboreSrU4mE+O798EVY/GOzfJpHRD2HyNQ/sa892saVP37j1tbW78uLy/f+H6TLz7wKkEsgaOfgFX6xs2wPh+ORZ/AU8YsWzk8PCwnJyeLs7OzX0HgIzYWcOsU4PszNUr3KDCJ9P2joyMDAYz583bAZiLnqM93rqHl9mh+lTW1V0DA4zP8OjDAK5XwthgE8BGk7gg0ubkxVYjJJIHN0u+1tziDEEEM2c2tr95XkjaknLEQJETGcEECl5wL5hKozf+dtZoBleB3d3cm6gSZgUEXAZAfUwH0Z2ZmLKO+RTeWpkJVlGrzmnYOXPb390HIMhMaBuahgLJqbjUJ88yA8hgCLVuaS1R6rQcHBwfm4OGCnDdaTrcNbiGlK+lPqtHAczFdFZszJTO3Cy2j/Ih0J/BsTrMET7gAMrNQEFx8HRYwHrEWDSRSJVoVwLe3txVWo7nPp1VCVdwGglNe9klgmksEXKO9ABCy7+3tgUgP3FQeKZBZYBIDo2CD1GlxIwQrHCxIYGP4FIBudd3d3QW4kVQq2yyXVI+AjBjggBJh0NGCLM+NBFKKawC+s7NTtre37fr6mgdSyeDrg5y1I/pBQHJ5FHD6IYN1GAbjN36YhNSbm5vFD5dydXVV0u8mriRg7faNcFMFLAPhWTkW2SL45ufnbWFhIcbX19frxsaGnZ+f0+IRgLp22t6tEjLQGHyUSyueHFB1bm7OlpeXy8rKip2enlY/2WKdG9SKU2kVu9B1OhdjQ/q1yuAo4ll06H93QQG4K1CXlpbs7OwsSEIRzDmR0Xo2slFCTMNCVizJXKDHMtal/+kCcyIVMXBxcRHK+XjUAxDhXjhDemAx8ikIOaisuQEawGmhAxdKjsAEiZubm9gG4yCBfdF6BZ/se/wdZKIHr7yopPWtASQBeGeMbNDCxfTL9K0aiNoGXrkYJDxssqn8TYW0rLmOOY8UpGWsglQhXUElWpxFKab/5e5XtFFOEklS7aLCcwDzrJgJwvQuUupHajMNK8/97k5Y0uIGmtaMUoySy8lYePlgndH01ngYxPJRuSUQQIFEyzWgBJ1KRI2I4HLi7Gt5z/VPaS2ATTqoIbER4JSt9yE3TBVaSUdwam3he6oS7yMCSoKqyJgSGvlQIt7k9LM+3QiK/aDUiwpQevTV511lG90FSx6tecNuhUwLGkHpal5+8MfknyrAvM1WMn2qqDAqr0oin9I3uYZXuSGFYtD0lwC1PO5co5KODhQlweLTkXkGKnPfJy7zp1RhVCzUNVKqi8rbERgFYJWLSK9Ozv91t3yeHB8f//YF7xzoW5Lo/3hwrKlAQi+REED+DyAZTP7z9x/efb+2tvb7P+WbcC6GhpheAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[0.5, -0.5, 0.5], [0.5, 0.5, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARdSURBVHgBdVfbURxBDBzB8ij4AFMEYAKgKDsSh8BlQAaE4BCcAs7AGdhVBABOAPMDFK+T1bJ6rmfrvFVzO6vdHbVaas2etTjOz88/vr+/f1sul2fu/iHOrYbHsLiXZ9hizns55xCbx7BYZ7BjwFbzq5hf3Nzc/DY4Dww/w3hQDxmdY14Ocv729taBxHxwWDZ9Jx3CFusziHynru/N7NNGHF9jchCjxTxO5phjEg962DA4TzO8tNWBe61Mxkhx0BkDq5Hg4jgE61Ms+kVeoLNcky8LIM4xnM55cB1SrUDEliDq+gwAmgaEh2DTRfkMAJIpUCrPOKPl4hxMC96tgHiN+4cJoJw6I9TFym71jBEsQWCxYsKlyBqpZk2gdgqogrSJ0eIGnAmNvrm5mQ9X1E76Khs9LULpoJYC0Rng+1rkE3IJEFl9RQ2LC3OAqMLrL0v+XYpQc/s/JjqbvDfBAS+kFpzRkY2qAxO1DAqYO2bvoERraBqSFabAmRPmV5jwaZpMixSLqyS5+Jrm5Mz/TAl9AIAX/U4Z0jnlV7pNkGAMA9VdNOS7dAp7DKvom9YDgQprxhRkQZQicmGqY11KyAAXoiN0R1BeQIaUlI+hVpIBrAsQovmh2HCN+1iUGBAFIi22shW/vr62l5cXx5kgmK51jktuyQCLz7WRsOiYM1yXWhIEaKY64PT5+RkArAAw911NDJAMl80TgORkaK9aMHguqzYKku88PT01OHx8fMwRAFiAWRcVdT+LqtjoXBmgrrsc6UhfQnS7u7u2t7eX9uvra7+7u2PkKufBqUq2mEtj74QlhL7h1IOueqdicN7a2rLT09N2eXlpx8fHuE7FBGhl0aRr9jS31c1/AKqzNTrhQ5RhNZ8cYAXO9/f3/ejoyCL6BAlGIj0YpvXCoWhoowzb3GEB4SJekaVawrnv7OwgBba9vZ1V//DwkMUbqcniAxC2d7KmjtnKcZ4EKY2KPinFInDOCMNxI+UozJJg+oAdIApwb9sclfKOKRnghdIm+c7oy3kOOCkH7PepBvmO6NtuMdm/sviBQ5YBwJlnk88xiZ4AUoIAUJENOyQ6nwAwqossCIgeXKaLLXWWs14DLDw6BZACxT2kU46zppTMshNyXc4HFUi1s4qdAOiUZ+ZRNN6bDXs/OiUZYG+gvMlUrs3INWoFAqdMh6RqkJdsxcZiRqo41/bOZsTNbtKql4JRh0YQkpYurbHDrjaaAkP9u27DLN5MAVUwzzvlQ4ZYkFKkPde1aZmtPlByDhBSlF7fnWln0BMXIhBSXzatjbX/Cap9uyhiaDqUHZ0y99wVUQP4i3Q4qwFXulUh2liEe93Iho9TBaGp6IHFz69Zs6AzTQ3zOXwJt1EG/a9XMcKacPke5PcF1fJ9I2hexOL38x5gY+vUJjVELwCaODRtUr46mqTpT5wvNhaLxW1c4F/qlUZO2tuwia22ZpMddA5CGOgF6qsPnvu4/hHTzycnJ7d/AfnXvAad7L5TAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[1, 0, 0], [0, 1, 0]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAASaSURBVHgBbVfbTR1LEJyG5f1xuUTgBJDlTJyCA0DyD3wg3giQ+LFEAk7BTgBCsCUSsBPA+AfEc9zVp2uoHTjSaGdnZ7uru6tr9ljx397e3runp6evz8/P7338X2stfi2+5tNquPq95Vo845xD1t7ci0G7Pr6528/n5+e/Dc79wQ8f/+Umy01qKOZq/PHxsTn0wTUCDudw2AUR7/gP99d3d3cfhunp6S90jgdwbC8/zMvU1JTBSl5huGJvmfziOlmK9zkvGhCufDd9LQ/D8HVwBx/jzYkjNVzVONBwXw7dWwRES3U6HM0FCMb7wZ3GBlxpoDfKZ8gO1pAJpFT21C7K0vMI73ZX7FkeMvIw0gGwdF6ZWpYA88wIs8D5K8KRE+BOAjUBaINEZ5lWRl0ZEVMOAOmcwzRTGl1PQj6TToh7kLAyIoAAoIxkRDLfZ5n+Vv/Mmmltte26FmTZTLOEEhizgIASTNXomF4YYVdoBrTmb+iBybqWIbIyZMSVZaCjRoSXaJGFZpwgSEAVHxGnyvp3vGjzKEGmrzJyqbu2X00QhgHRyWfxgE6x7sNSuEZq+EYbBgmDwWQnyJeEjHrDAJxD7WZmZiIryAA5kUQrVEfsSyCNiEK6V63KEjCdWudC9YPRJF8jKCLNrghwDw8P5f7+vuJKEKIDrxxnz0cXkIBVONDAwAj2wKCCgJPb29vY446L6zoAWAJg7UeOE3zjFFwxAyVbrLVVB6Qk0Or6DQ7E85ubmwKHuAIMgGTdW4uKQ1VOCl0daEzVrHaSLIDipfn5eVtcXIy1y8vLenV1xchH2aM9sf/KdgOQLG8HDsvCJmCGUjeqE9JWV1fj2dnZGe6jQ1RD8kQdxaJ8CwCibA1Id/JRdKIMGHC+tLRUV1ZWbG1tLd49PT3FekGJYJN84SAg8VMoxS1C7XsxEoDSOVqxzs3NoQQ2OzsbrF9fXw/enJycgCMAEUDZ4qKcfZAvJOSpxxYkGAgVnsEIDCN6dxzRsg0BYnNzM2wfHx9PFM73wg5A87gXEE3KlQMj51LvSGk6b9eMkJ9q0Q1bW1th6+joKPhE6c6TtPDckUxMpBhzSTfBMPow5I6jBSW9oxMQyoc1gMC7h4eHrX1T3qt89LSyUIoZtWXkjQOZxuYUQBJUOzeQAYoV3s1MVIAQ1usZ08g4KNFMjtqMngDIgcqSdKSuctRGRhxEPDw4OKCItc87tmEExNp09S9S+1HEfWvhx4MMCohgcBqiVNvb28EFZKL/5uT98IZjtl1VLpBAuqeUkUpWPWgABus7Ozuxf39/33i66ok7JEkUQNFSMEMsg3XilPziF06R/xX8zoxyYBNBYC99DSYqJ0TkWu3LY/KfQDVfOsJsLDpx9XI0TmTZJsexG772Tcu9Bmi6pYdHqkbj3cGjn+78K1ayHOHUM0ERK1Me5U+pa1FSSmnsRcLH/4jknDc5+2tmZcQN7PFMlN3dXf6R+Y5wPvm4ZoTqmIAo1X1a+7k4bJyQtQbEM2EbGxt/nJCf4+2Li4t33jZf3NjHvv69IIkwNZXkOjVD73td8flfHz9duj8tLCz8+gfV0LwG/iXJnwAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[0.5, 0.5, 0], [-0.5, 0.5, 0.5]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARlSURBVHgBfVfbcRRBDJTO6/cH4HIAOAIKInAIpEAGzoQIXJeCyQBHAB8OwARg4x/b5aeQdGpd33CwVVM3MzsrtaSWNKfiz3w+f29m85eXlw+vr6/vfC4+F/81X6sP83X85v74i3mt8c3KfoyQW/MzVT05PT39paHcMfzw8aZeah1upQSg956fn1sh7cVnOoBiIxKEP3Hm5uHh4ePkz1d/+SZeOCqdzWYpJEbM4zTm8SuLJ/Yx1zqTc1iKvZIl+La8Gr9vXfd85jo/u3CF8voVzOtpRfEu1j5MhocVr3H7CCjGhykExssSmi+gBMJiXR8YPMUAyCoWLsWl9FyEoDyE9cILoagUppCNjQ0gTst9nR8UQHgjPVIgtIaxtWS1Fh8UpAa4mE+wLhahLA4XqEZaZ3oNb4XiId6dAXA5ZQVbLlhPobSEaoFI4TGHpRw78ANWE/HYMlmThn+BiDGBdBXb/ChAEcvBelkTCmWusOvJcmUQFIacZwgofkgVSE9usPXFEYvMiTOV5/kt8p/qgCH+nBHsqQkkK6ZZhaLjTKa2F6LwIE0rRAalUYx8KAP6TxomCTOWYGcIBuKwuEiZyoA6QCMMKNtUlrWAoJxzRWROLThQIWhhiDOYHwDLYuReunRzc9O8lHZ5fnx8FB/29PQk5YHmwhrLFzF3cRECENCIAw0GtYHSE1aDvBpKHUwAyHn1BxmzA5yh9G0SSpXZJtwAJEGE1WEdUvX+/l5C4e3trdzd3UkpFzQuVD7whMs19tIDlGJGBzo1CVAe2NnZ0d3d3dy7uLiw6+trWL7iPaQvFA4AFpvn5+cGltuy2yHeNjQiNCvzTqaHh4dyfHwsBwcH5t4JLykIS2nMIo351iHgxsKMB0HRnMJbFQrd3983V6xXV1fpNV/HvgSwqpacyiRem8woxQKFXOW4ScVGKU/2b29v697enm5tbSXrnQv5TawdQIBIoEjxavdCyuGlJQfQ2UixlOIQkEJCcFjvitLaSlGLFCw5XSvibHmiawo3McjvLEBpxUGKd7oUloXiinc3JRQepKifSz7VmTQOYDgEMSY0HlIqpDgtL/cH0ZTc2zmOOyJ7DoynEBvCzGFBKYbVqPFwXzcguDSso3M6lmJd3qz4PtlgGWA8ExMNIIrxRgDAASgfb0dWzcfatZ4NdAvu+gAvYT6xMIq/UOwRBuMMUboHUCgU1/BQvnhtzS2AIS/JtEYx0q7b7XBbFmrFDaLuCD3XJd2zN6CeoLs2B1DXOe5ExM5nhEFX7whd3SgFG6wt75C4tHb48P30L8WI/RieGk3AUmLU9Toz8NQtSpX6Cm5V4YEbX79lJUzASsX+18RVjUan2QhAF/cHqf8fxkUoueHjJ8VVmJQUGqVavnJhHbpfhwGAas43497z8W3m1n5xoTewcI11qJTojCsdjuf4U8ucGAFR2H47IU9mR0dHl374oys4Y8vJE8SZZWvW5SV19AT+oECp2vK/QDw3Pv/u33+69OcPyNfomA1lhGkAAAAASUVORK5CYII=" alt=""/>
</td>
<td>
<code>[[0, 1, 0],[-1, 0, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAASMSURBVHgBbVc5Th1BEO2GYRNCxqQkvoFln8RX8A0cEpCwIwgccACfAMk+AXACk5DjAyDjBMTarle/XvGmYaRRr9OvlldVPbXYc3Jy8qG19uPp6enj8/Pze+sX6xdrm42rvc3GaH2erfbRxtseHx8rz5D5Iuf+nJqa+ra+vv6nAtxk+G2T77AhAB2coCKAtx24CucCmwAjgTAX5xXBuL67u/s02PPdBglukmEvPvA+LMQ+WoxrrZh3LdHGHt8HUBmrQjXGLcbLMzMzP6bssC92eMUDkGgL+/EkENYwhhAxX0IQBc2W8+KGKvs+DjgQC2i5QBB+LGt4Sgg1QQ2L0AJvCJEuCAuxdStA9TI9PU2NvU+NY9xC46LmiPVXwPqG1uRHpTAiXB2oHU4DGIgSFnA/i3X8YxGm979GzSsSdpoXjgeAYhInYyMtgD41pZZYC4FagDddV1+/8b4SAu9A0pFIWIRQ1C6eFms1ODMiZk801VxCuZAL0XrfXTD5PslVJNxIMNcOFqD5EDkv2BN/9kkqckTp/D7iiLuA0kRo1XBJEk9in9pnyPJbBUUmpECaDSkoBcCxQ2hCszgQ5ki+ICXBiiWuTLdhrVFKxny0RTKfC0ZQjRS6IA+j+ZmOIQz8KC5xLSyLNUulrj1A7+/vy8PDQ0MbFqBgGapdlnSeDfQrFCTzmXxIOuyhOUXrGhZycBOmWFtNCPX9KEeEYprGk4R+sNSB0sU3CdjMBRmqt7e3buqbmxt/AzyTTuQRAjZN25xDMUrThwBFQ0sfEm5+fr4uLCz43MXFRbu6uqrqc5KV4UvAt85UCzT6P794KTgsRCxWbonj4+NydnZWV1ZWmnECVqqMpCRWWJc6lHF+mQjQFxYB9CkWJ7SwmIHVw8PDdnR0VFdXV91qi4uLmMf6aL+cozKRSxMSElAKTh5AjbAPGoL9e3t79eDgoC4tLTX43bjg38/NzcEyLmQUOHdDlPsi4LRSowCpuQBngYLJcQgO3tnZqfv7+wUcgEBgPKIgiJn1AHvjXpE5pU9uJRIRzaRmZxmGOStNb+Bld3e3zM7OEtCFZuJhTYGVWLxoRQqjLsA7sPAw79Pv0I6kA/j29nazt4p5RxpTAGqo4cuLQ+Sbom5hKqbP8x4oIGVrawsC0LeNbC+RUKQOpGYEjPDOhNS54CUKSD5KFr4vm5ubEIAJiOC57yW/NOdDmnYYFOfVdY99CjAiH/1FcLqDfFBCxeF0RZV7QArWhWKGJi8kPbBbA8D2koQ9eFP15I6QfU1CsEyRKkj3uQWY1zX2NzY2SoAXYW+THDG6LYWWVcHpd173sA+WlPHYArSCgUP7LE6qefdPUMX8TapeRgafuEumm/HwVgUOXNvCMhbD5xq3WQ96K+ijYdYLUCf3B5Z3DfkJN6w9D7Y3mF4ThhJSPspaISQkcLqBAvFCwktpd0n5hQ8+rK2t/bbishya1y57ZZWLQuO+jNqQ+UJaP4PjcONIkTj/r72fwYFLU+KTffDd+l+UkCSTxj1dwCvVW5cXccfopzTY/8/656bM19PT08v/abDlBeCmFPkAAAAASUVORK5CYII=" alt=""/>
</td>
<td>
<code>[[-0.5, 0.5, 0.5],[-0.5, -0.5, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAARPSURBVHgBdVfNVR4xDLQ/lv8DBBpIBzxSASXkzikd0ElKgBJIB+kgOXCHFMALJ/5B0QiNvllD9j0/eb22NJZGsrc3fy4vLz+b2enr6+vBy8vLJ5cNzcfMZfdmPg7ZXDbKse/TIWNu9ht1pT7OO19ZWTk5Pj7+02HcMfzywR1MSINhnEYFQI09Pz/TuIILwPzGtRhLfU1s3Nzf3x8uHMn3xWKx4611f1yaCzgm+mjsQ7a3xxo7Zj1l9GFU3mtDCaKLN3ZXV1dPXe/iq7cuxiEb+/kEIMgEimY5GIYGoyU5Loa7zDmYoBAvqTQm0xAXu5dCAlQa6wSwdISV8gFEhSA9YDJvd5JdYWIYw4NF+ObvsQBzIAmUIFIZDTRtdL2EgGDKG1MqjgnYIT4QEIzwnYsJgCDEBZo1/yNhF4AxPmGHGQIsLIXopze4KN4TEAlp+l1j/UHrCjBttImkI5HwwABTK31tBJWc6R95YMj7MAY9mn4ShugzBMWsJCKD3BhnzCMZoTwzpwiorpciZcqDgRsBfCLJ7I1hlqFoEuuuXsA07Iph4FoaRTHyQtTHyilZoTwIEkYs+YEgmI70Asfogaenp8CmO0ZL41EpxfUt06+KFUM+Zb7T9TOy2bIca/pBcfcqZg8PDwEeRh1Q82YpO3fO9FTypfHKAhYfYxYw9Ug6EgxNQeAb5OPjY3MwaD13bgP7K/7JmSrp9ECxn4TT0irV0KZpYnq2u7u7cPXt7W007D6BVuWjJFnFAzHm+qZyfTK+aWrpQ4UbGxt9c3MzvHFxcWHX19ddY676BoMznSQ5T78qKnRzjs0yAaSFp5wDfX9/vx0dHbW9vT28w0vU19WISD1R30KQ7jRZMFPAfOcpCI+tra31ra0tc8Pddx9e297ebgCBEHEuQylh7gqozoLRoLgnAGFnmJfxjxA4gMgEENC5EGvW19cR0wCZR3qn1zSLZJPlgRrUwybLdFxKYByK4Xr3QKPLkd8AoedG1HgBIQecnqQhJ/kwGreMabCeO4PhNF4nJsiHDKCr4RnWE56s4hEl4FsppnG4RK5m3H0owjymoCiuHRNEMTuzgYZZkMRO2GQprokEoY0eSElO1H2BRQrfkY5JMMv60bUEj5ybxEVkO6XROPo0Os5blog4pIyuzfA1mVAhYtkPYmtsmDpEORpnNgyEqt1lva+bEwCx7GrF5TtATJqzsvMuRad2LsZt2L4eOi09UemM97a8ORV5yYERQPFh6GuazqpZ7rILkIo7uCHcmufgCEAyYOaNEaR6QA8cJRuPXhriSUvsvFXhx+RGYyqkNHF3hUVjLwYIwmy4dpn8I+T9YnZdh9bfYqgpwz94r5uw7saWt2INAzlh9v4fwfKO8QP/ht9c0Y2kmYZD2Vu/Yn1e19sHZFQwNFjeyTD9dXmyuPLH1x66ovP+vhx3ISO50FloaFSM60+HKRju3KfeuPzpOr6cnZ1d/QPcnvFZAc/1wgAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[-1, 0, 1], [0, -1, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAScSURBVHgBfVdLblw3ECTnjYTRB4oiXcC7ICsn2QmCfoAOoWVyA9/AcwcdwNtk59xAEqB1cgTnAEIsLSTo2+7q6aJq6LEfQJDDx9ddrK5ucmrxx8zeePvw8vLy9vn5+UfvC5rPmffVm/k8+uJ9Yb9ojLX4Rn4XsRfrvP84DMO73d3d/wb3/+bu7u6f4+Pjn3w88VYBqtYK/zFOkHXWzeZgMOfbHAHDER3Ke5Nvfn56evr95OTkLwcyfLi8vHzrDsvh4WGlYzSM01mMaVwd5Voy0TsvySDX1WQD48loNPoFAP6E9bOzs3ACEPhQgaij3EHpndPpItq7eQX5wzAej6fYPR4HAcfVQaCPcYajpHPjrrredLcKRtjihpS9ybC0tEQA4eH8/Dz8HhwczGkhATQaaSxprwqgE6DSbhKSsDEsLy9Pc4eVu04mIhypwSZAoX9ux8wEZou0xoBqBPbwGwDe504rKc9wVAqTIOiYH3cpV7+Vfny3kIHJZDJ1Narv2L0wARAUQBNkR2/xtPqqHiRIBdVAJBs2rK6uThl/kqBkOIgAQ01QdGIYjgCgKohFOiCDDAUaALxXtYMNjhdookhqxg7p+PHxkQAMc3jHpuFQ5wA2rK2tTUl5PiZMtJAgO+D46Ogo1JhO4JgtAOj8ghKt4ZsxsL6+HhrwVrK1MRjP3wHIQcRH+/v7wQCcPjw82P39ffUGp0Yw4twYBt19luY6bGxsTHO3RkcZisLfGLMHCIz39vbgvPg5Ur2hLwCSTJimpYZBCxGeYXNzc6oOlAHMeamOcfbmfb24uIh3Ozs75ebmplxfX5fb29sCQB0DVeuAVEimZRnDMKscsyHPAs63+o81MLiyslJPT09jHil6dXXVMkDPCR5mYn/OJp5xxjre5VHYxGczK3omMEzmBSyyA9Pb29vmJZ3sGZ1lZhfJqjAp9WbGAHeuRYi/ex344VXg3Fmwra2t6ruPbz2d450DqRpSTekeEMCMc3HLfS6SFnHHOndQfWxePas7rO7MEHePfzDn8yE+AKFdMNKnNVmCbTJQ+vwn9ViMBufcoTOAHsIMTQBE2ol3CqJnEE9ecGI9GWjlV2iLneOBcRhkS+clRdYKD78FM3HQZAZhAxRit8EQoclhZCzHFBR6GAL1ZIGGKVoexwDBzTDvcy1Dwe8YghBhzbjwHDCpiq0GSKMmLNOylVy8RzrqZsrrMV6Z2hnaGDMNSXeRamgpvEINsBDputcyYQgF05a3aK0LhU7ZMwRlQQkujD2dSl9EN/Su9wOjyADIusssbIKtltaas9m3YtNrQZxrsdH7P/UwV0uwHmWZIoU9gtQsKF3s+xNS07TK7lndgoVU/NzNCe+gHTglY99joPZsKEjqQ3ZYBcTcea8lt2OgAQeAzz632cXfxKmJ6OaolSdiz3Vy8w0byUzcDcrroTRj2Bf8S6cSirmCIdWsZnotBCEpZ6KJpg17/U/Bub9HHps/wIII7ys9UGvcUZ0/4coCMepfOoIwvQt6/7/370Z+pH7yb391Rx/7up1iqypKEWAz2Od7Xj5MwfBe6Es/e3/m/W/T6fTTF0V6AXDEjsqqAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[-0.5, -0.5, 1], [0.5, -0.5, 0.5]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAPxSURBVHgBdVdbUhsxEJyB/TBVgM0Jwg2SY+SW+c0flRNwI2xeHxSwE7V2Wm7J662SV9ZK6p6e0UgyW577Uh5LeSolWNx9Ht76LS4vL2tZG7NWZPxDKT9MwPelYODMTjqREuH3i4uL2O12sd1uZ9SzfVaSWWpbzjHLvMC8vyw/f0rjTzApb8+PzjpeEcG6l7rB6pubG7+7u7Orq6va9vn5yX62DG2Pyzunre9Nef8Cgb/8SJAcENLeJirgVsCtWG+FgG82m6XzkURHYKyTZP7fTh3VpUM3CP/5wPLr62uAe5EeLmCfyH7++vpq39/fbS4xhMqGGLWbhGUoY5ETk3taXmW/vb2t1oNEKtbchefl5aURF4s9ubqQ80ksJUuqESp7sRwBB1BDgfVQYlAqCChKELR9U2UmAW1Bgg7sXCLc0+cO0AQnmRaYdgyw9pCEGsj+7AsCXQPZ+fJUuelvksgYqG5QwCSuLvXiDp/n2dQNiVnrdEEIy9qxWF6jHeAASmBLFYIk0lUnSzCJRCrhVEIf9J3E1zEEnKnVAE35AYxgrG6wY3A1y9PnnUsYmLoMUZ8k+OjzmmTE2qYCA5DgWBHqPkky6k7W4+3tzYo7XNsn8Q2TjIJTfg1AUwWooES2WR9XoUE6ro62DJleFYh+HtoaiUxEapHLchRXu8YGlHCSQAxAdssMF2ugfNNqJXLm0bROhUJXCVYHGiZGO9PrOYtH6ZMQTfUhDhqJNSXYB+640CCRrar5L7dSztCyWo7hxCFIoSR0NSgbPhN8UZjot0Yk5dLZGqjJ5rLf7+35+dkOhwPejjcL27NP+4YVUbCXIEQFDWn5an5XYN2A0Fgm9AQLBc/2IDDIgEjBCmCaZEKQCGQslUdyhG6hPvg1xFIHAP9ncVXo/f295gKO1/NAXRpQQvzVDiRnzgi1zyi3Ws3/KftJSp40kaCeMeGaIXVzGU449Y/4f9VqKAPZsSlpuq4Ehk2kgoIEpFKL5YBxcrJRBQSYrvGVFNysmI4Y0SXyr6+vYGBKDOiZsU0oknfxgDfWOixfWYFHAmPk53JzLlEFX0k4bXkV61vUJzijXd1mJ5vRwC7U/5gg88SYUJoCKb0uwZrv5SDS3MVYazFgZx45ajFPdPIr27S45QKCywHUBxInMaBH8pODY5Ko/lQFOPkgO3c6k3k60roSQOBQyi76+0AMHevfYlXkEu0ActkF06udV1Vdt5xBSvlty/2wy3ZrquTgKCukuefj48MkybhsYpwnZD4flP1nCb7PXa+7nHpeKHNAd1PGASbPD90N2YebNOfx4dZc/j8ltpHEgw4UwHPX7Fmv5zpOQcd2W27FjwT/D10eWMXiUGZJAAAAAElFTkSuQmCC" alt=""/>
</td>
<td>
<code>[[0, -1, 1], [1, 0, 0]]、[[1, 0, 0], [0, 1, 0]]、[[0, 1, 0], [-1, 0, 1]]、[[-1, 0, 1], [0, -1, 1]]</code>
</td>
</tr>
<tr>
<td>
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAO2SURBVHgBdVftURwxDJUOM/CDj00HdMAkFaSEtJAO0klKoIWkklBCUkE44AcD3DmS46d71vo8c3Nrr209PT3JXhVr5+fnNycnJ3fv7++3qvpBeqvWrK/4p3Ghbh6r9htfprbZbH7s9/tvLy8vf3RZlpvT09NfNnjtL8lQbEQAVpszOH+2fRzw8L6PVYD0+W9vbw/Pz88fy+vr6/ezs7Pry8tLKaUoed0M9r15fACnIxU6YUf53/cx7+Xp6WmxeXfFOl98gRmXi4uL2kFIN65Eb2zOINgYPMeY9817YUZ2u52acXRvCy82HTiIBma2uPYO6WI2nkFE+LpxDu1SiKq20vTQQBiYIf5gITGCzQNQDkEPZfPcYp41pCXFqsJzDwdA9I2DcjIyDYuMzWOuj4+PwzvsV0idCg/9z41fXV05mBDRxNCUHezRPRczDrArgIXsAlnQ7kw4CANTQWfyfKgNckDahqyueMzDKWih79MAFdBBOpLERLVwqAuU6K+IrT8DHIVLeqpxGmeA7b+wSmcUed+NGxOuCRhSAoFnbNo8N8GNxeBA1ihCWq3ERiCGx66Jnh3CCZBVjzzvoRRiJVjmsBUSYMQJz5xmvqAz0YRJICIcRnvtxge1Z70ICaHAi8QCkA9MeHNhetlGimKNq90FB8ayQ8wEsfBfhCzmTFECVEkTDQwZZ+/i4IJBCgE7V4dCxJN48mxjpKj3Lc8HL9NcyWEmELLh/Tn9aKzS5qiGjA7OVFoTIFKtWHlV+AXiJ3TKcX4zE76me+6HzLE0C0+zEPuYQgOrM50mclo2Wr22b7db5SLkhYeZoQJUU1YIjUUlBHX5QoF6DyFJP1jCAy5C/g75X+n2Q4DyWDCwmkhJHqDcy36wBDvMGOZgnFidFiFvDiBXwSi3nLMW54o8JwDTi6pXQzYCJhkN1hb2oB+9lZnoGwrK66wCEqAA0iex14PO8IA6EFQCGThzSv0mA6M8Lxeo5GUTJoDp4S4xODdkQZqgPearbwOmO4HJV/cKYXLjfsmGEfd+sMT1XMbaUBMDucgMGeV78XoWaZFJ44MFDAGYru+CfDGVRJZSOFjsKw0EpU4ZBCfrb4PZuHI/gWOGBk2AVT+OH+xh8cmk9pqp1VH+Mw0c7nSIQ11d0ZsmALQxYGP3Nukz8py84LJ6zFvePGsk9knrQxOW9j/j49TO+CVNHgCQBmb3xgFLej8cyRi0e+Nf+31qAw7CP1L9O5HpOuJpFl9+X1P8NY1vzfN7+/9qn+e//wG+/jPiLcn4PAAAAABJRU5ErkJggg==" alt=""/>
</td>
<td>
<code>[[-0.5, -0.5, 1], [0.5, -0.5, 0.5]]、[[0.5, -0.5, 0.5], [0.5, 0.5, 0]]、[[0.5, 0.5, 0], [-0.5, 0.5, 0.5]]、[[-0.5, 0.5, 0.5], [-0.5, -0.5, 1]]</code>
</td>
</tr>
</tbody>
</table>


## 填充与描边

填充与描边属性的值都包含一个或多个 Paint 的数组，在文本图层上填充支持 Mixed 类型。

描边还有几个相关的属性用控制粗细、样式、转角处形状等等，在 Vector 类型的图层上 strokeCap 和 strokeJoin 支持 Mixed 类型。 Figma 不像其他软件可以分别定义不同描边粗细等属性，粗细等属性是控制所有描边的，可以这样理解 Figma 其实只支持一个描边，但描边的颜色可以叠加多个色彩。

```typescript
// Figma Plugin API Typings
interface GeometryMixin {
  fills: ReadonlyArray<Paint> | PluginAPI['mixed']
  strokes: ReadonlyArray<Paint>
  strokeWeight: number
  strokeMiterLimit: number
  strokeAlign: "CENTER" | "INSIDE" | "OUTSIDE"
  strokeCap: StrokeCap | PluginAPI['mixed']
  strokeJoin: StrokeJoin | PluginAPI['mixed']
  dashPattern: ReadonlyArray<number>
  // ...
}
type StrokeCap = "NONE" | "ROUND" | "SQUARE" | "ARROW_LINES" | "ARROW_EQUILATERAL"
type StrokeJoin = "MITER" | "BEVEL" | "ROUND"
```

除了填充与描边的 ReadonlyArray 和 Paint 对象，需要考虑对象拷贝的问题外，其他描边属性相关的属性都是直接赋值修改的。

```typescript
let layer = figma.currentPage.selection[0] as GeometryMixin;
let blackPaint = Color('000000').paint;
layer.fills = [{...blackPaint, opacity: 0.1}];
layer.strokes = [blackPaint];
layer.strokeWeight = 2;
layer.strokeAlign = "CENTER";
```

## 特效

图层的特效属性也是 ReadonlyArray，特效目前有两种，投影 ShadowEffect 和模糊 BlurEffect，投影支持两种类型外投影和内投影，模糊之处两种类型图层模糊和背景模糊。

```typescript
// Figma Plugin API Typings
interface BlendMixin {
  opacity: number
  blendMode: BlendMode
  isMask: boolean
  effects: ReadonlyArray<Effect>
  effectStyleId: string
}
  
interface ShadowEffect {
  readonly type: "DROP_SHADOW" | "INNER_SHADOW"
  readonly color: RGBA
  readonly offset: Vector
  readonly radius: number
  readonly visible: boolean
  readonly blendMode: BlendMode
}

interface BlurEffect {
  readonly type: "LAYER_BLUR" | "BACKGROUND_BLUR"
  readonly radius: number
  readonly visible: boolean
}

type Effect = ShadowEffect | BlurEffect

interface Vector {
  readonly x: number
  readonly y: number
}
```

在声明 Effect 对象时所有属性都是必须赋值的。

```typescript
let layer = figma.currentPage.selection[0] as BlendMixin;
layer.effects = [
  {
    type: "DROP_SHADOW",
    color: {r: 0, g: 0, b: 0, a: 1},
    offset: {x: 0, y: 1},
    radius: 10,
    visible: true,
    blendMode: 'NORMAL'
  }
];
```

## 创建基础图形

```typescript
// Figma Plugin API Typings
interface PluginAPI {
	// ...
  createRectangle(): RectangleNode
  createLine(): LineNode
  createEllipse(): EllipseNode
  createPolygon(): PolygonNode
  createStar(): StarNode
  createVector(): VectorNode
  createText(): TextNode
  createFrame(): FrameNode
  createComponent(): ComponentNode
  createSlice(): SliceNode
  // ...
  createNodeFromSvg(svg: string): FrameNode
}
```

使用 Figma Plugin API 的做法是先创建图形，再修改各种属性的值，然后插入到页面中。不同的图层类型会有不同的属性，具体可以参考官方文档或声明文件。

```typescript
let layer = figma.createRectangle();
layer.x = 0;
layer.y = 0;
layer.resize(24, 24);
layer.fills = [
  {
    type: "SOLID",
    color: {r: 1, g: 0, b: 0}
  }
];
figma.currentPage.appendChild(layer);
```

Scripter 增加了一些创建图形的函数，可以直接将图层属性作为参数。

```typescript
// Scripter Typings
declare function Rectangle(props? :NodeProps<RectangleNode>) :RectangleNode;
declare function Line(props? :NodeProps<LineNode>|null): LineNode;
declare function Ellipse(props? :NodeProps<EllipseNode>|null): EllipseNode;
declare function Polygon(props? :NodeProps<PolygonNode>|null): PolygonNode;
declare function Star(props? :NodeProps<StarNode>|null): StarNode;
declare function Vector(props? :NodeProps<VectorNode>|null): VectorNode;
declare function Text(props? :NodeProps<TextNode>|null): TextNode;
declare function Frame(props? :NodeProps<FrameNode>|null, ...children :SceneNode[]): FrameNode;
declare function Component(props? :NodeProps<ComponentNode>|null, ...children :SceneNode[]): ComponentNode;
declare function Slice(props? :NodeProps<SliceNode>|null): SliceNode;
```

将属性作为参数可以解决相同属性共用的问题。

```typescript
let propreies: NodeProps<RectangleNode> = {
  x: 0,
  y: 0,
  width: 24,
  height: 24,
  fills: [RED.paint]
};
addToPage(Rectangle(propreies));
addToPage(Rectangle({...propreies, x: 48, y: 0}));
```

