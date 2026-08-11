import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DailyReflectionSheet extends StatefulWidget {
  final DateTime date;
  final DailyReflectionEntity? existingReflection;
  final Function(DailyReflectionEntity) onSave;

  const DailyReflectionSheet({
    super.key,
    required this.date,
    this.existingReflection,
    required this.onSave,
  });

  @override
  State<DailyReflectionSheet> createState() => _DailyReflectionSheetState();
}

class _DailyReflectionSheetState extends State<DailyReflectionSheet> {
  late TextEditingController _lessonController;
  late TextEditingController _notesController;
  int _moodRating = 5;

  @override
  void initState() {
    super.initState();
    _lessonController = TextEditingController(
      text: widget.existingReflection?.todayLesson ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingReflection?.memorableNotes ?? '',
    );
    _moodRating = widget.existingReflection?.moodRating ?? 5;
  }

  @override
  void dispose() {
    _lessonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final reflection = DailyReflectionEntity(
      id: widget.existingReflection?.id ?? const Uuid().v4(),
      date: widget.date,
      todayLesson: _lessonController.text.trim(),
      memorableNotes: _notesController.text.trim(),
      moodRating: _moodRating,
    );

    widget.onSave(reflection);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Evaluasi & Refleksi Hari Ini',
                        style: AppTheme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pelajaran Hari Ini (Learning Everyday)',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _lessonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Apa hal atau ilmu baru yang kamu pelajari hari ini?',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Catatan Berkesan Hari Ini',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Momen atau ucapan syukur apa yang terjadi hari ini?',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Perasaan Hari Ini',
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodIcon(1, '😢'),
                  _buildMoodIcon(2, '😕'),
                  _buildMoodIcon(3, '😐'),
                  _buildMoodIcon(4, '🙂'),
                  _buildMoodIcon(5, '😄'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Simpan Refleksi Hari Ini',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIcon(int value, String emoji) {
    final isSelected = _moodRating == value;
    return GestureDetector(
      onTap: () => setState(() => _moodRating = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.background,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 22)),
      ),
    );
  }
}
