import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

typedef OnSubmit = void Function(String title, String category, String time);

const _newCategory = '__new__';

/// Asks for a new category name, saves it, and returns it.
Future<String?> showCreateCategoryDialog(BuildContext context) async {
  final controller = TextEditingController();
  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  final userId = Provider.of<UserProvider>(context, listen: false).userId;
  String? error;

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('New category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. Anime'),
            ),
            if (error != null) ...[
              const SizedBox(height: Space.s),
              Text(error!, style: dialogContext.type.bodySmall),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final ok = await categoryProvider.addAndSaveCategory(name, userId);
              if (!dialogContext.mounted) return;
              if (ok) {
                await categoryProvider.loadCategoriesFromDatabase(userId);
                if (dialogContext.mounted) Navigator.pop(dialogContext, name);
              } else {
                setState(() => error = 'That category already exists, or it could not be saved.');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

/// The add and edit task sheet used by the dashboard, calendar and tasks.
/// The time is always handed back as a 12-hour clock ("4:20 PM"), whatever
/// the phone's own clock setting.
void showTaskDialog({
  required BuildContext context,
  required String dialogTitle,
  String? initialTitle,
  String? initialCategory,
  String? initialTime,
  required OnSubmit onSubmit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TaskSheet(
      title: dialogTitle,
      initialTitle: initialTitle,
      initialCategory: initialCategory,
      initialTime: initialTime,
      onSubmit: onSubmit,
    ),
  );
}

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({
    required this.title,
    required this.onSubmit,
    this.initialTitle,
    this.initialCategory,
    this.initialTime,
  });

  final String title;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialTime;
  final OnSubmit onSubmit;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  late final TextEditingController _title = TextEditingController(text: widget.initialTitle ?? '');
  late String? _category = widget.initialCategory;
  late TimeOfDay? _time =
      widget.initialTime == null ? null : PlannerFormat.parseTime(widget.initialTime!);
  bool _tried = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    setState(() => _tried = true);
    final title = _title.text.trim();
    if (title.isEmpty || _category == null || _time == null) return;
    widget.onSubmit(title, _category!, PlannerFormat.clock(_time!.hour, _time!.minute));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final categories = Provider.of<CategoryProvider>(context).categoriesForDropdown;
    final options = [
      ...categories,
      if (_category != null && !categories.contains(_category)) _category!,
    ];
    final missing = [
      if (_title.text.trim().isEmpty) 'a title',
      if (_category == null) 'a category',
      if (_time == null) 'a time',
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.m, Space.page, Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: context.type.headlineSmall),
            const SizedBox(height: Space.m),
            const Kicker('What'),
            const SizedBox(height: Space.xs),
            TextField(
              controller: _title,
              autofocus: widget.initialTitle == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Watch Frieren ep. 12'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.gutter),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Kicker('Category'),
                      const SizedBox(height: Space.xs),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        dropdownColor: c.paper,
                        hint: const Text('Choose'),
                        items: [
                          for (final cat in options) DropdownMenuItem(value: cat, child: Text(cat)),
                          const DropdownMenuItem(value: _newCategory, child: Text('New category…')),
                        ],
                        onChanged: (value) async {
                          if (value == _newCategory) {
                            final created = await showCreateCategoryDialog(context);
                            if (!mounted) return;
                            setState(() => _category = created ?? _category);
                          } else {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.gutter),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Kicker('Time'),
                      const SizedBox(height: Space.xs),
                      Semantics(
                        button: true,
                        label: _time == null ? 'Choose a time' : 'Time, ${PlannerFormat.clock(_time!.hour, _time!.minute)}',
                        child: InkWell(
                          onTap: _pickTime,
                          borderRadius: Radii.controlAll,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(Icons.schedule, size: 18),
                            ),
                            child: Text(
                              _time == null ? 'Choose' : PlannerFormat.clock(_time!.hour, _time!.minute),
                              style: context.type.bodyMedium?.copyWith(
                                color: _time == null ? c.inkMuted : c.ink,
                                fontFeatures: TypeScale.tabular,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_tried && missing.isNotEmpty) ...[
              const SizedBox(height: Space.s),
              Text('Add ${missing.join(', ')} to save.', style: context.type.bodySmall?.copyWith(color: c.ink)),
            ],
            const SizedBox(height: Space.l),
            InkButton(label: 'Save task', onPressed: _save, expand: true),
            const SizedBox(height: Space.xs),
            InkButton.quiet(label: 'Cancel', onPressed: () => Navigator.pop(context), expand: true),
          ],
        ),
      ),
    );
  }
}
