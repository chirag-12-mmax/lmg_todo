import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class HorizontalCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const HorizontalCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  late DateTime _selectedDate;
  late List<DateTime> _days;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _days = _daysInMonth(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      // sync with parent updates (e.g., external state changes)
      _selectedDate = widget.selectedDate;
      _days = _daysInMonth(_selectedDate);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  List<DateTime> _daysInMonth(DateTime date) {
    final last = DateTime(date.year, date.month + 1, 0);
    return List.generate(
      last.day,
      (i) => DateTime(date.year, date.month, i + 1),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onTap(DateTime date) {
    // 1) instant local highlight
    setState(() {
      _selectedDate = date;
      // if month changed (future-proof), rebuild days
      _days = _daysInMonth(_selectedDate);
    });

    // 2) notify parent
    widget.onDateSelected(date);

    // 3) center the selected item
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected({bool animated = true}) {
    const itemWidth = 72.0;
    final screenWidth = MediaQuery.of(context).size.width;

    final selectedIndex =
        _days.indexWhere((d) => _isSameDate(d, _selectedDate));
    if (selectedIndex == -1) return;

    final targetOffset =
        (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    void go() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final clamped = targetOffset.clamp(0.0, max);
      if (animated) {
        _scrollController.animateTo(
          clamped,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(clamped);
      }
    }

    if (_scrollController.hasClients) {
      go();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
    }
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacing16),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = _isSameDate(date, _selectedDate);

          return GestureDetector(
            onTap: () => _onTap(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: AppStyles.spacing12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppStyles.radius12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: AppStyles.heading3.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacing2),
                  Text(
                    _getDayAbbreviation(date.weekday),
                    style: AppStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
