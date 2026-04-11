import 'package:flutter/material.dart';
import '../../services/exam_service.dart';
import 'exam_screen.dart';

class ExamVariantsScreen extends StatefulWidget {
  final Map<String, dynamic> examSubject;

  const ExamVariantsScreen({Key? key, required this.examSubject}) : super(key: key);

  @override
  State<ExamVariantsScreen> createState() => _ExamVariantsScreenState();
}

class _ExamVariantsScreenState extends State<ExamVariantsScreen> {
  final _examService = ExamService();
  List<Map<String, dynamic>> _variants = [];
  List<int> _availableYears = [];
  int? _selectedYear;
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    setState(() => _isLoading = true);
    final response = await _examService.getVariants(
      widget.examSubject['id'],
      year: _selectedYear,
    );
    if (response['success'] == true && mounted) {
      setState(() {
        _variants = List<Map<String, dynamic>>.from(response['data']);
        _availableYears = List<int>.from(response['available_years'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateVariant() async {
    final year = _selectedYear ?? DateTime.now().year;
    setState(() => _isGenerating = true);
    final response = await _examService.generateVariant(widget.examSubject['id'], year);
    setState(() => _isGenerating = false);
    if (response['success'] == true && mounted) {
      await _loadVariants();
      final newVariant = response['data'] as Map<String, dynamic>;
      _startExam(newVariant);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message'] ?? 'Ошибка генерации'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _startExam(Map<String, dynamic> variant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamScreen(
          variant: variant,
          examSubject: widget.examSubject,
        ),
      ),
    ).then((_) => _loadVariants());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final examType = widget.examSubject['exam_type'] as String;
    final accentColor = examType == 'ege' ? const Color(0xFF8B2FC9) : const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [accentColor.withOpacity(0.15), theme.scaffoldBackgroundColor]
                : [accentColor.withOpacity(0.08), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: accentColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            examType.toUpperCase(),
                            style: TextStyle(fontSize: 13, color: accentColor, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.examSubject['name'],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Кнопка генерации + фильтр года
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Кнопка генерации
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isGenerating ? null : _generateVariant,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: _isGenerating
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome_rounded, size: 20),
                        label: Text(
                          _isGenerating ? 'Генерация...' : 'Сгенерировать вариант',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Фильтр по году
                    if (_availableYears.isNotEmpty)
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildYearChip(null, 'Все годы', accentColor),
                            ..._availableYears.map((y) => _buildYearChip(y, '$y', accentColor)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Список вариантов
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentColor))
                    : _variants.isEmpty
                    ? _buildEmpty(accentColor)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _variants.length,
                  itemBuilder: (context, index) => _buildVariantCard(_variants[index], accentColor, isDark, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearChip(int? year, String label, Color color) {
    final isSelected = _selectedYear == year;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedYear = year);
        _loadVariants();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildVariantCard(Map<String, dynamic> variant, Color color, bool isDark, ThemeData theme) {
    final isCompleted = variant['is_completed'] == true;
    final isGenerated = variant['is_generated'] == true;
    final primaryScore = variant['primary_score'];
    final testScore = variant['test_score'];
    final grade = variant['grade'];

    return GestureDetector(
      onTap: () => _startExam(variant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isCompleted ? Border.all(color: Colors.green.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24)
                    : Icon(isGenerated ? Icons.auto_awesome_rounded : Icons.description_rounded, color: color, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Вариант ${variant['variant_number']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.titleMedium?.color),
                      ),
                      const SizedBox(width: 8),
                      if (isGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('авто', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${variant['year']} год',
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                  if (isCompleted && primaryScore != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildScoreBadge('$primaryScore пб', Colors.blue),
                        if (testScore != null) ...[const SizedBox(width: 6), _buildScoreBadge('$testScore тб', Colors.purple)],
                        if (grade != null) ...[const SizedBox(width: 6), _buildScoreBadge('Оценка: $grade', Colors.orange)],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmpty(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded, size: 64, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Вариантов пока нет', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text('Нажмите «Сгенерировать вариант»\nчтобы создать первый', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}