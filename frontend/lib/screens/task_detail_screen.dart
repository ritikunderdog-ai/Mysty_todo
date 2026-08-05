import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/models/task.dart';
import 'package:mysty/providers/task_provider.dart';
import 'package:mysty/providers/category_provider.dart';
import 'package:intl/intl.dart';

/// Task creation/editing screen with cyberpunk-styled form fields.
class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'MEDIUM';
  DateTime? _dueDate;
  int? _categoryId;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _priority = widget.task!.priority.name;
      if (widget.task!.dueDate != null) {
        _dueDate = DateTime.parse(widget.task!.dueDate!);
      }
      _categoryId = widget.task!.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDIT TASK' : 'NEW TASK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildLabel('TITLE'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  color: CyberpunkColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              _buildLabel('DESCRIPTION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(
                  color: CyberpunkColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add details...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Priority
              _buildLabel('PRIORITY'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityButton('LOW', CyberpunkColors.priorityLow),
                  const SizedBox(width: 8),
                  _buildPriorityButton('MEDIUM', CyberpunkColors.priorityMedium),
                  const SizedBox(width: 8),
                  _buildPriorityButton('HIGH', CyberpunkColors.priorityHigh),
                ],
              ),
              const SizedBox(height: 24),

              // Due Date
              _buildLabel('DUE DATE'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CyberpunkColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CyberpunkColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: CyberpunkColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate != null
                            ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                            : 'No due date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? CyberpunkColors.textPrimary
                              : CyberpunkColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: const Icon(Icons.clear,
                              color: CyberpunkColors.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category
              _buildLabel('CATEGORY'),
              const SizedBox(height: 8),
              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: CyberpunkColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CyberpunkColors.cardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _categoryId,
                        isExpanded: true,
                        dropdownColor: CyberpunkColors.surface,
                        hint: const Text(
                          'No category',
                          style: TextStyle(
                            color: CyberpunkColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'No category',
                              style: TextStyle(
                                color: CyberpunkColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ...provider.categories.map((c) {
                            return DropdownMenuItem<int?>(
                              value: c.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _parseColor(c.color),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      color: CyberpunkColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _categoryId = value);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberpunkColors.primary,
                    foregroundColor: CyberpunkColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CyberpunkColors.background,
                          ),
                        )
                      : Text(
                          _isEditing ? 'UPDATE TASK' : 'CREATE TASK',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: CyberpunkColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildPriorityButton(String value, Color color) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : CyberpunkColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : CyberpunkColors.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)]
                : [],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? color : CyberpunkColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CyberpunkColors.primary,
              surface: CyberpunkColors.surface,
              onSurface: CyberpunkColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final success = await provider.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate != null
          ? DateFormat('yyyy-MM-dd').format(_dueDate!)
          : null,
      categoryId: _categoryId,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return CyberpunkColors.primary;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
