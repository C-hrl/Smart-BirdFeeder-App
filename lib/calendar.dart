import 'package:flutter/material.dart';
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
      child: Column(
        children: [
          SizedBox(
            height: 305,
            child: TableCalendar(
              rowHeight: 45,
              daysOfWeekHeight: 16,
              currentDay: currentlySelectedDay,
              focusedDay: currentlySelectedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2030),
              onDaySelected: (selectedDay, focusedDay) {
                ref.watch(selectedDayProvider.notifier).state = selectedDay;
              },
            ),
          ),
          const BirdList()
        ],
      ),
    );
  }
}

//List of birds displayed under the calendar
class BirdList extends ConsumerWidget {
  const BirdList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(15),
        // ignore: prefer_const_constructors
        children: const [BirdCard(), BirdCard(), BirdCard(), BirdCard()],
      ),
    );
  }
}

class BirdCard extends StatelessWidget {
  const BirdCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16)),
                child: Image.asset(
                  "images/birdie_sanders.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
