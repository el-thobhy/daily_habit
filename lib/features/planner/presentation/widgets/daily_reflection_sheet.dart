import 'dart:convert';
import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  int _moodRating = 5;

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _lessonController = TextEditingController(
      text: widget.existingReflection?.todayLesson ?? '',
    );
    _quillController = _initQuillController(
      widget.existingReflection?.memorableNotes,
    );
    _moodRating = widget.existingReflection?.moodRating ?? 5;
  }

  QuillController _initQuillController(String? content) {
    if (content == null || content.trim().isEmpty) {
      return QuillController.basic();
    }
    try {
      final json = jsonDecode(content);
      return QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      final doc = Document()..insert(0, content);
      return QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _lessonController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final notesDeltaJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    final reflection = DailyReflectionEntity(
      id: widget.existingReflection?.id ?? const Uuid().v4(),
      date: widget.date,
      todayLesson: _lessonController.text.trim(),
      memorableNotes: notesDeltaJson,
      moodRating: _moodRating,
    );

    widget.onSave(reflection);
    Navigator.pop(context);
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWide = mediaQuery.size.width > 600;

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _toggleFullscreen,
            icon: const Icon(Icons.fullscreen_exit),
            tooltip: 'Keluar Fullscreen',
          ),
          title: Text(
            'Catatan Berkesan Hari Ini',
            style: AppTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: AppTheme.primary),
              tooltip: 'Simpan',
            ),
          ],
        ),
        body: Column(
          children: [
            const Divider(height: 1, color: AppTheme.border),
            Container(
              color: AppTheme.background,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: QuillSimpleToolbar(
                  controller: _quillController,
                  config: const QuillSimpleToolbarConfig(
                    toolbarIconAlignment: WrapAlignment.start,
                    toolbarIconCrossAlignment: WrapCrossAlignment.center,
                    axis: Axis.horizontal,
                    showSmallButton: true,
                    showInlineCode: false,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            Expanded(
              child: Container(
                color: AppTheme.background,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: QuillEditor.basic(
                  controller: _quillController,
                  scrollController: _editorScrollController,
                  focusNode: _editorFocusNode,
                  config: const QuillEditorConfig(
                    placeholder:
                        'Momen atau ucapan syukur apa yang terjadi hari ini...',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget sheetContent = SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: mediaQuery.viewInsets.bottom + 24,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catatan Berkesan Hari Ini',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: _toggleFullscreen,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Fullscreen',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: QuillSimpleToolbar(
                        controller: _quillController,
                        config: const QuillSimpleToolbarConfig(
                          toolbarIconAlignment: WrapAlignment.start,
                          toolbarIconCrossAlignment: WrapCrossAlignment.center,
                          axis: Axis.horizontal,
                          showSmallButton: true,
                          showInlineCode: false,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.border),
                    Container(
                      height: 150,
                      padding: const EdgeInsets.all(12),
                      child: QuillEditor.basic(
                        controller: _quillController,
                        scrollController: _editorScrollController,
                        focusNode: _editorFocusNode,
                        config: const QuillEditorConfig(
                          placeholder:
                              'Momen atau ucapan syukur apa yang terjadi hari ini...',
                        ),
                      ),
                    ),
                  ],
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

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Material(color: Colors.transparent, child: sheetContent),
        ),
      );
    }

    return sheetContent;
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
              ? AppTheme.primary.withValues(alpha: 0.15)
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
