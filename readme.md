# Figma Scripter 编程

?> 教程目前尚处于撰写过程，部分章节会出现无内容或不完整的情况。欢迎通过 [Github Issues](https://github.com/ashung/learning-figma-scripter/issues) 提供示例素材。

## 关于教程

设计师要不要学编程？这是一个会引发很多设计师争执的问题。实际上很多界面设计软件，包括 Photoshop，Illustrator，XD，Sketch 和 Figma 都有让用户通过编程方式操控软件的功能，动画软件 After Effects 和三维软件都有这样的设定。我认为设计师在否定这个问题的时候，应该思考一下为什么在给设计师使用的软件上加入这个功能，应该去体验这个功能。

Figma 是一款个人免费的网页端设计工具，操作简单容易上手，在团队协作方面有着其他设计工具目前还无法超越的优势，插件的出现也让设计师能够更快速的执行一些特定操作，越来越多的设计师和公司选择将 Figma 作为主要设计工具。尽管有了目前 Figma 社区上已经有许多插件，但插件通常满足的是一些通用的需求。如果要处理某些特殊操作，这时插件往往会不尽如人意，甚至很多时候无法找到一个合适的插件。

很多设计师经常发问，有什么插件可以快速处理某个事情。能够提出这个问题，比那些只会埋头苦干的人，已经聪明很多，因为他们可能会得到一个改变他们日后工作方式的答案。见过很多埋头苦干的勤奋的人，从使用 Photoshop，到历尽艰辛百般不愿的换到 Sketch，他们可能不会用上 Figma。我也从放弃写 Photoshop 的代码，到只写 Sketch 和 Figma 的代码。

又有人要问，你把我要需求作出插件就行了，为什么要让我看代码？我在维护 [Automate Sketch](https://github.com/Ashung/Automate-Sketch) 插件的这么长时间里，就经常遇到用户提出各种奇怪的需求，有些我会把他们提出的需求改成比较通用的操作加入到 Automate 上，有些实在太特殊，虽然没几行代码不浪时间，我也只会丢给他们代码，让他们自己去运行。有些设计师根本不知道他们看到的那几个输入框，开发起来却要花很多时间。另外由于 Figma 的插件机制，无法将很多功能集合在一个插件上，而且发布一个新的插件，审核通常就要花一两周时间。让用户从源码安装插件门槛又比较高，而且还没有更新机制。这时 Scripter 这样一个通过运行脚本来操作 Figma 的插件就非常便利。

教程中会尽可能详细列出 Figma 用户，包括设计师、开发的各种可能的操作，例如高效的选择图层、重命名图层、绘图、生成代码等等。尽量做到，让那些特别恐惧代码的设计师，也能找到解决问题要那个代码，然后复制粘贴运行。就好像他在某个网站下载了新版的 Sketch，然后一直被提示文件损坏，这时在百度搜到一个救急方法，他翻遍了启动台里的图标终于找到 “终端”，粘贴下那行这辈子也无法理解的东西，猛地拍下回车，这一刻他好像在发射火箭，但是发射失败了，那个 “终端” 没有任何反应，不过他再次点击下载里的 Sketch 的图标时已经可以启动了。如果你懂那些代码的意思，只需要稍微修改代码上的参数就能够适用自己的情况，也可举一反三得到更多有用的代码。

本教程不是针对设计师的 Figma 基础教程，而是针对有 Figma 基础的设计师，但想要通过学习编程来实现 Figma 自动化。所以如果您是一位设计师，完全没有 Figma 基础，本教程目前完全不适合您。教程内使用的编程语言和您的朋友圈上的 Python 没有半点关系，没有那么厉害但也不差。另外也不用对 Figma 脚本抱有太大的期望，设计师不会因为学会 Figma 的脚本编程而像学会 Python 一样人生开挂不加班，一日扣图几百张，但是我可能会有自动扣图的教程。

如果您是一位现在还在一线写代码的 Web 前端开发或者懂前端开发的设计师，那么您可以忽略此教程，除非您想无偿为这个教程作出一点贡献。“Figma Scripter 编程” 项目以完全开源的形式托管在 [Github](https://github.com/ashung/learning-figma-scripter) 上，文档以 Markdown格式保存，通过 [Docsify](https://docsify.js.org) 生成这个网站。

对于没有任何 Figma 基础的人，可以通过以下网站自学。

- [官方帮助文档](https://help.figma.com/hc/en-us) 英文版。
- [FigmaChina](https://figmachina.com) 的官方帮助文档的民间中文翻译版。
- [Figmacn](https://figmacn.com/) 的文章、教程和免费资源。

## 关于作者

如果您是由 Sketch 转到 Figma 的用户，可能已经在 Sketch 上用过的我的 [Automate Sketch](https://github.com/Ashung/Automate-Sketch) 插件。

如果您是一位 Automate 的深度用户，却考虑转到 Figma 来。在这里我要回答一下很多用户提出的问题。由于 Figma 的插件支持，我无法实现一个 Automate 的 Figma 版本，但是 Automate 的一些功能，其实 Figma 本身就自带，您也可以搜索到某个功能的插件。实际我在 Figma 插件的内测期间就开发了一款用于导出 Android 资源的插件，并且随第一批插件发布了，而且这段时间我也陆续发布了[一些 Figma 插件](https://www.figma.com/@ashung)，我会将 Automate 中一些可以在 Figma 中实现，并且目前还没有插件实现的功能，逐渐实现到 Figma 插件，或者在 Scripter 上实现。

即使您没有用过 Sketch，也有可能安装过我的 [Figma 插件](https://www.figma.com/@ashung)。

## 问题反馈

如有关于教程中的错误、范例需求、以及任何问题，都可以通过发起 Github [Issues](https://github.com/ashung/learning-figma-scripter/issues) 形式反馈，**请勿发起无关信息**。

## 版权声明

文档及代码采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) 授权。

任何个人或组织，出于商业目的，可以使用本文档的链接形式，但未经允许不得复制或修改内容，并发布至存在经济收益的媒体上，包括但不限于公众号、营利性微信群、收费的任何知识付费平台或培训课程等等。

## 赞助

作者没有公众号，没有某某星球，没加入各种知识付费平台和培训机构，但不拒绝读者在同意作者不会给你任何福利的条件下，通过合法的金钱或实际物资给予作者赞助和支持。还有您的赞助，不一定会转成更新这个教程的动力，但是一定会转换为猫粮。

以下是可用的赞助方式：

<img src="images/donate_wechat_pay.jpg" alt="微信" title="微信"  width="100" height="100">
<img src="images/donate_alipay.jpg" alt="支付宝" title="支付宝"  width="100" height="100">
<img src="images/donate_wechat.jpg" alt="微信赞赏码" title="微信赞赏码" width="100" height="100">

[PayPal](https://www.paypal.me/ashung),  [Buy Me a Coffee](https://www.buymeacoffee.com/ashung)