#Arabic Root Pro (阿拉伯语词根分析器)

这是一个基于 Flutter 开发的高级阿拉伯语形态学分析工具。它不依赖庞大的词典数据库，而是通过轻量级算法 (Light Stemming) 和正则模式匹配引擎 (Pattern Matching Engine)，从复杂的阿拉伯语单词中精准提取三字母词根 (Triliteral Roots)，并计算两个单词之间的词源相似度。

核心功能

智能词根提取 (Smart Extraction): 能够识别并还原阿拉伯语动词的 十式 (Forms I-X) 变化。

复杂词式支持: 除了动词，还支持工具名词、比较级/最高级形容词、主动/被动分词等。

输入清洗 (Sanitization):

自动去除所有元音符号 (Tashkeel/Harakat)。

规范化字母 (Unifying Alef/Yaa)。

智能忽略 ة (Ta Marbuta)，提高名词匹配率。

首词锁定: 输入整句时，自动仅截取第一个空格前的单词进行分析，防止干扰。

相似度计算: 使用 Levenshtein 编辑距离算法计算提取出的词根相似度。

RTL 支持: 完美适配阿拉伯语的从右向左 (Right-to-Left) 布局。

支持的形态学模式 (Morphological Patterns)

本程序内置了一个基于优先级的正则匹配引擎，支持以下词式（按优先级排序）：

优先级

词式名称 (Pattern Name)

示例 (Example)

提取词根 (Root)

1

Form X (Past/Present/Part)

يستعمل (Yasta'mil)

ع-م-ل

2

Instrumental Noun (Mif'aal)

مفتاح (Miftaah)

ف-ت-ح

3

Form I Passive (Maf'ul)

مكتوب (Maktub)

ك-ت-ب

4

Form VII (Infa'ala)

انكسر (Inkasara)

ك-س-ر

5

Form VIII (Ifta'ala)

اجتمع (Ijtama'a)

ج-م-ع

6

Form VI (Tafa'ala)

تفاعل (Tafa'ala)

ف-ع-ل

7

Form III / Active Participle

كاتب (Katib)

ك-ت-ب

8

Form V (Tafa''ala)

تكلّم (Takallama)

ك-ل-م

9

Masdar Form II/V (Taf'aal)

تمثال (Timthal)

م-ث-ل

10

Comparative/Elative (Af'al)

أكبر (Akbar)

ك-b-r

11

Comparative Fem (Fu'la)

كبرى (Kubra)

ك-b-r

12

Form IV (Af'ala)

أكرم (Akrama)

ك-ر-م

注：如果单词不符合上述任何复杂模式，系统将回退到基础的前缀/后缀剥离算法 (Fallback Stripping)。

算法原理

1. 预处理 (Normalization)

在分析之前，会对输入字符串进行严格清洗：

去噪: 移除 \u064B-\u065F (Tanween, Shadda 等) 及 \u0640 (Tatweel)。

归一化: 将 أ, إ, آ 统一转为 ا；将 ى 转为 ا。

噪音过滤: 直接删除 ة (Ta Marbuta)，例如将 مكتبة (图书馆) 处理为 مكتب，以便匹配 maf'al 模式。

2. 模式匹配引擎 (Pattern Engine)

引擎按照特异性递减 (Specificity Descent) 的顺序遍历正则库。

原则: "越长、特征越明显的模式越先匹配"。

例如：Mustaf'il (7个字母) 会优先于 Fa'il (4个字母) 被检测，防止因过度切分导致错误。

3. 相似度判定

提取出两个单词的词根 (Root A 和 Root B) 后，计算它们的 Levenshtein 编辑距离：

距离 0: 绝对同根 (如 Kitab vs Maktub -> k-t-b).

距离 1: 高度相似 (允许弱字母变化，如 Qala vs Qawl).

如何运行

本项目是一个标准的 Flutter 单文件应用。

确保已安装 Flutter SDK。

创建新项目或使用现有项目。

将 main.dart 的内容替换为本项目代码。

运行：

flutter run


交互说明

输入: 在 Word A 和 Word B 输入框中输入阿拉伯语单词（支持直接粘贴整句，系统会自动截取首词）。

分析: 点击 "分析词根与句式" 按钮。

结果: 底部卡片将显示：

匹配到的具体词式 (如 Form X (Present)).

提取出的三字母词根.

两者是否为同根词的判定结果.

Developed for Arabic NLP processing with Dart.
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
