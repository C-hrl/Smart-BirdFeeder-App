import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

final selectedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class CalendarDisplay extends ConsumerWidget {
  const CalendarDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedDay = ref.watch(selectedDayProvider);
    return Expanded(
      child: TableCalendar(
        currentDay: currentlySelectedDay,
        focusedDay: currentlySelectedDay,
        firstDay: DateTime(2000),
        lastDay: DateTime(2030),
        onDaySelected: (selectedDay, focusedDay) {
          ref.watch(selectedDayProvider.notifier).state = selectedDay;
        },
      ),
    );
  }
}
