import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ArabicMatcherApp());
}

class ArabicMatcherApp extends StatelessWidget {
  const ArabicMatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic Root Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Arial', // 确保有阿拉伯语字体支持
      ),
      home: const SimilarityScreen(),
    );
  }
}

class SimilarityScreen extends StatefulWidget {
  const SimilarityScreen({super.key});

  @override
  State<SimilarityScreen> createState() => _SimilarityScreenState();
}

class _SimilarityScreenState extends State<SimilarityScreen> {
  final TextEditingController _wordAController = TextEditingController();
  final TextEditingController _wordBController = TextEditingController();
  final ArabicStemmer _stemmer = ArabicStemmer();

  String _normA = ""; 
  String _normB = ""; 
  String _rootA = "";
  String _rootB = "";
  int _distance = 0;
  bool _isMatch = false;
  bool _hasChecked = false;
  String? _matchedPatternA; // 用于显示匹配到了哪个式
  String? _matchedPatternB;

  void _checkSimilarity() {
    // 获取原始输入
    final rawA = _wordAController.text.trim();
    final rawB = _wordBController.text.trim();

    if (rawA.isEmpty || rawB.isEmpty) return;

    FocusScope.of(context).unfocus();

    // Stability Fix: 仅截取第一个空格前的内容 (只处理第一个单词)
    final wordA = rawA.split(RegExp(r'\s+')).first;
    final wordB = rawB.split(RegExp(r'\s+')).first;

    setState(() {
      // 1. 预处理
      _normA = _stemmer.normalize(wordA);
      _normB = _stemmer.normalize(wordB);

      // 2. 提取词根
      final resA = _stemmer.analyze(wordA);
      final resB = _stemmer.analyze(wordB);

      _rootA = resA.root;
      _matchedPatternA = resA.patternName;
      
      _rootB = resB.root;
      _matchedPatternB = resB.patternName;
      
      // 3. 计算距离
      _distance = getLevenshtein(_rootA, _rootB);
      
      // 4. 判定逻辑
      _isMatch = (_rootA == _rootB) || (_distance <= 1);
      _hasChecked = true;
    });
  }

  void _fillTestCase(String a, String b) {
    _wordAController.text = a;
    _wordBController.text = b;
    _checkSimilarity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arabic Forms & Roots'),
        backgroundColor: Colors.teal.shade50,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _buildInput(controller: _wordAController, label: 'Word A'),
                  const SizedBox(height: 16),
                  _buildInput(controller: _wordBController, label: 'Word B'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _checkSimilarity,
              icon: const Icon(Icons.analytics),
              label: const Text('分析词根与句式 (Analyze)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 32),

            if (_hasChecked) _buildResultCard(),
            
            const SizedBox(height: 40),
            const Divider(),
            const Center(child: Text("新增功能测试用例", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: const Text('工具名词: Miftaah (Key)'),
                  onPressed: () => _fillTestCase('مفتاح', 'فتح'),
                ),
                ActionChip(
                  label: const Text('比较级: Akbar (Bigger)'),
                  onPressed: () => _fillTestCase('أكبر', 'كبير'),
                ),
                ActionChip(
                  label: const Text('最高级阴性: Kubra'),
                  onPressed: () => _fillTestCase('كبرى', 'كبير'),
                ),
                ActionChip(
                  label: const Text('忽略 ة 测试: Maktaba'),
                  onPressed: () => _fillTestCase('مكتبة', 'كتب'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
        helperText: "输入整句时，仅提取首个单词",
        helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _isMatch ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isMatch ? Icons.check_circle : Icons.cancel, 
                  color: _isMatch ? Colors.green : Colors.deepOrange, size: 28),
                const SizedBox(width: 8),
                Text(
                  _isMatch ? "Root Match" : "Mismatch",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: _isMatch ? Colors.green.shade800 : Colors.deepOrange.shade800
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow("Pattern Used:", _matchedPatternA ?? "N/A", _matchedPatternB ?? "N/A", isSmall: true),
            const SizedBox(height: 8),
            _buildDetailRow("Extracted Root:", _rootA, _rootB, isHighlight: true),
            const SizedBox(height: 8),
            Text(
               "Levenshtein Distance: $_distance",
               style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String valA, String valB, {bool isHighlight = false, bool isSmall = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(valA, style: TextStyle(
              fontFamily: isSmall ? 'Arial' : 'Courier', 
              fontSize: isHighlight ? 24 : (isSmall ? 14 : 16), 
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.teal.shade800 : Colors.black87
            )),
            const Icon(Icons.arrow_right_alt, size: 16, color: Colors.black26),
            Text(valB, style: TextStyle(
              fontFamily: isSmall ? 'Arial' : 'Courier', 
              fontSize: isHighlight ? 24 : (isSmall ? 14 : 16),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.teal.shade800 : Colors.black87
            )),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// 核心算法部分 (Pattern Engine)
// ==========================================

class AnalysisResult {
  final String root;
  final String patternName;
  AnalysisResult(this.root, this.patternName);
}

class _RootPattern {
  final String name; 
  final RegExp regex;
  // [R1_group_index, R2_group_index, R3_group_index]
  final List<int> groups; 

  _RootPattern(this.name, String pattern, {this.groups = const [1, 2, 3]}) 
      : regex = RegExp(pattern);
}

class ArabicStemmer {
  // 1. 元音范围
  static final _diacritics = RegExp(r'[\u064B-\u065F\u0640\u0670\u06D6-\u06ED]');
  
  // 2. 定义模式库 (优先级：长/特异性 -> 短/通用性)
  static final List<_RootPattern> _patterns = [
    // --- Form X (استفعل) ---
    _RootPattern("Form X (Past)", r'^است(.)(.)(.)$'), 
    _RootPattern("Form X (Present)", r'^يست(.)(.)(.)$'), 
    _RootPattern("Form X (Participle)", r'^مست(.)(.)(.)$'),
    
    // --- [新增] Instrumental (Mif'aal - مفعال) ---
    // e.g., Miftah (مفتاح) -> F-T-H
    // 正则：Meem + R1 + R2 + Alef + R3
    _RootPattern("Instrumental (Mif'aal)", r'^م(.)(.)ا(.)$'),

    // --- Form I Passive (مفعول) ---
    // e.g., Maktub (مكتوب)
    // 正则：Meem + R1 + R2 + Waw + R3
    _RootPattern("Form I (Passive)", r'^م(.)(.)و(.)$'), 

    // --- Form VII (انفعل) ---
    _RootPattern("Form VII (Past)", r'^ان(.)(.)(.)$'), 
    _RootPattern("Form VII (Present)", r'^ين(.)(.)(.)$'),
    _RootPattern("Form VII (Participle)", r'^من(.)(.)(.)$'), 

    // --- Form VIII (افتعل) ---
    _RootPattern("Form VIII (Past)", r'^ا(.)ت(.)(.)$'), 
    _RootPattern("Form VIII (Present)", r'^ي(.)ت(.)(.)$'), 
    _RootPattern("Form VIII (Participle)", r'^م(.)ت(.)(.)$'), 

    // --- Form VI (تفاعل) ---
    _RootPattern("Form VI (Past)", r'^ت(.)ا(.)(.)$'), 
    _RootPattern("Form VI (Present)", r'^يت(.)ا(.)(.)$'), 
    _RootPattern("Form VI (Participle)", r'^مت(.)ا(.)(.)$'), 

    // --- Form III (فاعل) ---
    _RootPattern("Form III/I-Active", r'^(.)ا(.)(.)$'), 
    _RootPattern("Form III (Present)", r'^ي(.)ا(.)(.)$'), 
    _RootPattern("Form III (Participle)", r'^م(.)ا(.)(.)$'), 

    // --- Form V (تفعّل) ---
    _RootPattern("Form V (Past)", r'^ت(.)(.)(.)$'), 
    _RootPattern("Form V (Present)", r'^يت(.)(.)(.)$'),
    _RootPattern("Form V (Participle)", r'^مت(.)(.)(.)$'),

    // --- Masdar Form II/V (Taf'aal) ---
    _RootPattern("Masdar (Taf'aal)", r'^ت(.)(.)ا(.)$'), 

    // --- [新增] Elative/Comparative (Af'al - أفعل) ---
    // e.g., Akbar (أكبر) -> K-B-R
    // 归一化后为: Alef + R1 + R2 + R3
    // 注意：这也涵盖了 Form IV Past (Af'ala - أكرم)
    _RootPattern("Comparative (Af'al)", r'^ا(.)(.)(.)$'), 

    // --- [新增] Elative Fem (Fu'la - فعلى) ---
    // e.g., Kubra (كبرى) -> K-B-R
    // 归一化后：R1 + R2 + R3 + Alef (from Yaa/Alif Maqsura)
    // 必须是4个字母，以Alef结尾
    _RootPattern("Comparative Fem (Fu'la)", r'^(.)(.)(.)ا$'),

    // --- Form IV (Participle) ---
    _RootPattern("Form IV (Participle)", r'^م(.)(.)(.)$'), 
    
    // --- Default Form I Present (Yaf'alu) ---
    _RootPattern("Form I (Present)", r'^ي(.)(.)(.)$'),
  ];

  String normalize(String text) {
    if (text.isEmpty) return "";
    String res = text.replaceAll(_diacritics, '');
    res = res.replaceAll(RegExp(r'[أإآ]'), 'ا');
    res = res.replaceAll('ى', 'ا');
    
    // [修改] 忽略所有 "ة" (Ta Marbuta)，直接删除
    // 之前是替换为 'ه'，现在按照需求删除，以便处理如 'مكتبة' -> 'مكتب'
    res = res.replaceAll('ة', '');
    
    return res.trim();
  }

  AnalysisResult analyze(String word) {
    String stem = normalize(word);
    if (stem.length <= 2) return AnalysisResult(stem, "Too Short");

    for (final pattern in _patterns) {
      final match = pattern.regex.firstMatch(stem);
      if (match != null) {
        String r1 = match.group(pattern.groups[0])!;
        String r2 = match.group(pattern.groups[1])!;
        String r3 = match.group(pattern.groups[2])!;
        return AnalysisResult(r1 + r2 + r3, pattern.name);
      }
    }

    String fallbackRoot = _fallbackStripping(stem);
    return AnalysisResult(fallbackRoot, "Fallback/Form I");
  }

  String extractRoot(String word) {
    return analyze(word).root;
  }

  String _fallbackStripping(String stem) {
    String s = stem;
    
    if (s.startsWith('وال') || s.startsWith('فال')) s = s.substring(1);
    if (s.startsWith('لل') || s.startsWith('ال')) s = s.substring(2);
    if (s.length > 3 && (s.startsWith('و') || s.startsWith('ف'))) s = s.substring(1);

    if (s.length > 4) {
       if (s.endsWith('ات') || s.endsWith('ون') || s.endsWith('ين')) s = s.substring(0, s.length - 2);
       else if (s.endsWith('ي')) s = s.substring(0, s.length - 1);
       // 注意：这里去掉了对 'ه' (Ha) 的移除，因为我们不再把 'ة' 转为 'ه'
       // 如果 'ه' 是原生字母或代词后缀，仍需小心
    }

    return s;
  }
}

int getLevenshtein(String s, String t) {
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;

  List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
  List<int> v1 = List<int>.filled(t.length + 1, 0);

  for (int i = 0; i < s.length; i++) {
    v1[0] = i + 1;
    for (int j = 0; j < t.length; j++) {
      int cost = (s[i] == t[j]) ? 0 : 1;
      v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
    }
    for (int j = 0; j < t.length + 1; j++) v0[j] = v1[j];
  }
  return v1[t.length];
}