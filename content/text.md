# 文本



```typescript
interface PluginAPI {
  // ...
	createText(): TextNode
  // ...
  listAvailableFontsAsync(): Promise<Font[]>
  loadFontAsync(fontName: FontName): Promise<void>
	// ...
}

interface TextNode extends DefaultShapeMixin, ConstraintMixin {
  readonly type: "TEXT"
  clone(): TextNode
  readonly hasMissingFont: boolean
  textAlignHorizontal: "LEFT" | "CENTER" | "RIGHT" | "JUSTIFIED"
  textAlignVertical: "TOP" | "CENTER" | "BOTTOM"
  textAutoResize: "NONE" | "WIDTH_AND_HEIGHT" | "HEIGHT"
  paragraphIndent: number
  paragraphSpacing: number
  autoRename: boolean

  textStyleId: string | PluginAPI['mixed']
  fontSize: number | PluginAPI['mixed']
  fontName: FontName | PluginAPI['mixed']
  textCase: TextCase | PluginAPI['mixed']
  textDecoration: TextDecoration | PluginAPI['mixed']
  letterSpacing: LetterSpacing | PluginAPI['mixed']
  lineHeight: LineHeight | PluginAPI['mixed']

  characters: string
  insertCharacters(start: number, characters: string, useStyle?: "BEFORE" | "AFTER"): void
  deleteCharacters(start: number, end: number): void

  getRangeFontSize(start: number, end: number): number | PluginAPI['mixed']
  setRangeFontSize(start: number, end: number, value: number): void
  getRangeFontName(start: number, end: number): FontName | PluginAPI['mixed']
  setRangeFontName(start: number, end: number, value: FontName): void
  getRangeTextCase(start: number, end: number): TextCase | PluginAPI['mixed']
  setRangeTextCase(start: number, end: number, value: TextCase): void
  getRangeTextDecoration(start: number, end: number): TextDecoration | PluginAPI['mixed']
  setRangeTextDecoration(start: number, end: number, value: TextDecoration): void
  getRangeLetterSpacing(start: number, end: number): LetterSpacing | PluginAPI['mixed']
  setRangeLetterSpacing(start: number, end: number, value: LetterSpacing): void
  getRangeLineHeight(start: number, end: number): LineHeight | PluginAPI['mixed']
  setRangeLineHeight(start: number, end: number, value: LineHeight): void
  getRangeFills(start: number, end: number): Paint[] | PluginAPI['mixed']
  setRangeFills(start: number, end: number, value: Paint[]): void
  getRangeTextStyleId(start: number, end: number): string | PluginAPI['mixed']
  setRangeTextStyleId(start: number, end: number, value: string): void
  getRangeFillStyleId(start: number, end: number): string | PluginAPI['mixed']
  setRangeFillStyleId(start: number, end: number, value: string): void
}

interface FontName {
  readonly family: string
  readonly style: string
}
  
type TextCase = "ORIGINAL" | "UPPER" | "LOWER" | "TITLE"

type TextDecoration = "NONE" | "UNDERLINE" | "STRIKETHROUGH"

interface LetterSpacing {
  readonly value: number
  readonly unit: "PIXELS" | "PERCENT"
}

type LineHeight = {
  readonly value: number
  readonly unit: "PIXELS" | "PERCENT"
} | {
	readonly unit: "AUTO"
}
```



```
declare function Text(props? :NodeProps<TextNode>|null): TextNode;
```



## 可用字体



​    listAvailableFontsAsync(): Promise<Font[]>    loadFontAsync(fontName: FontName): Promise<void>    readonly hasMissingFont: boolean







selectedTextRange: { node: TextNode, start: number, end: number } | null