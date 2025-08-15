import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final Todo? todo;

  const AddTodoBottomSheet({super.key, this.todo});

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedMinutes = 1;
  int _selectedSeconds = 0;
  int _selectedPriority = 0;
  DateTime? _selectedDueDate;

  late TodoProvider _todoProvider;

  @override
  void initState() {
    super.initState();
    _todoProvider = Get.find<TodoProvider>();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedMinutes = widget.todo!.duration ~/ 60;
      _selectedSeconds = widget.todo!.duration % 60;
      _selectedPriority = widget.todo!.priority;
      if (widget.todo!.dueDate != null) {
        _selectedDueDate = widget.todo!.dueDate;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radius20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppStyles.spacing20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: AppStyles.spacing16),
                      _buildDescriptionField(),
                      const SizedBox(height: AppStyles.spacing16),
                      _buildTimeSection(),
                      const SizedBox(height: AppStyles.spacing16),
                      _buildPrioritySection(),
                      const SizedBox(height: AppStyles.spacing16),
                      _buildDueDateSection(),
                      const SizedBox(height: AppStyles.spacing24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms);
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppStyles.spacing12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppStyles.radius2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      child: Row(
        children: [
          Text(
            widget.todo == null ? 'Add New Task' : 'Edit Task',
            style: AppStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        hintText: 'Enter task title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter task description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radius12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      maxLines: 3,
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (Max 5 minutes)',
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedMinutes,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                items: List.generate(6, (index) => index)
                    .map((minutes) => DropdownMenuItem(
                          value: minutes,
                          child: Text('$minutes min'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMinutes = value ?? 1;
                  });
                },
              ),
            ),
            const SizedBox(width: AppStyles.spacing12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedSeconds,
                decoration: InputDecoration(
                  labelText: 'Seconds',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                items: List.generate(60, (index) => index)
                    .map((seconds) => DropdownMenuItem(
                          value: seconds,
                          child: Text('$seconds sec'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeconds = value ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        Row(
          children: [
            _buildPriorityChip('None', 0, AppColors.textTertiary),
            const SizedBox(width: AppStyles.spacing8),
            _buildPriorityChip('Low', 1, AppColors.warning),
            const SizedBox(width: AppStyles.spacing8),
            _buildPriorityChip('High', 2, AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, int priority, Color color) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spacing16,
          vertical: AppStyles.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.radius20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date (Optional)',
          style: AppStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacing8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppStyles.radius12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppStyles.spacing12),
                Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : 'Select due date',
                  style: AppStyles.bodyMedium.copyWith(
                    color: _selectedDueDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (_selectedDueDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(vertical: AppStyles.spacing16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radius12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppStyles.spacing12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              padding:
                  const EdgeInsets.symmetric(vertical: AppStyles.spacing16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radius12),
              ),
              elevation: 2,
            ),
            child: Text(
              widget.todo == null ? 'Add Task' : 'Update Task',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final initialDate =
        (_selectedDueDate != null && _selectedDueDate!.isBefore(firstDate))
            ? firstDate
            : (_selectedDueDate ?? firstDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final duration = (_selectedMinutes * 60) + _selectedSeconds;
    if (duration == 0) {
      Get.snackbar(
        'Error',
        'Please set a duration greater than 0',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
      return;
    }

    final todo = Todo(
      id: widget.todo?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: widget.todo?.status ?? 'TODO',
      duration: duration,
      elapsedTime: widget.todo?.elapsedTime ?? 0,
      startTime: widget.todo?.startTime,
      endTime: widget.todo?.endTime,
      date: _selectedDueDate ?? DateTime.now(),
      createdDate: widget.todo?.createdDate ?? DateTime.now(),
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      isCompleted: widget.todo?.isCompleted ?? false,
    );

    try {
      if (widget.todo == null) {
        await _todoProvider.addTodo(todo);

        Get.back();
        Get.snackbar(
          'Success',
          'Task added successfully',
          backgroundColor: AppColors.secondary,
          colorText: AppColors.textInverse,
        ); // Close the bottom sheet after adding
      } else {
        await _todoProvider.updateTodo(todo);
        

        Get.back();
        Get.snackbar(
          'Success',
          'Task updated successfully',
          backgroundColor: AppColors.secondary,
          colorText: AppColors.textInverse,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save task',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }
  }
}
