import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_bird_feeder/database/Database.dart';
import 'package:smart_bird_feeder/theme/styles.dart';
import 'package:smart_bird_feeder/theme/theme.dart';
import 'package:smart_bird_feeder/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

final selectedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class CalendarDisplay extends ConsumerWidget {
  const CalendarDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedDay = ref.watch(selectedDayProvider);
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfDateRangePicker(
                selectionColor: colorBlue,
                todayHighlightColor: colorBlue,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center, textStyle: calendarTitle),
                selectionTextStyle: calendarText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//List of birds displayed under the calendar
class BirdList extends ConsumerWidget {
  const BirdList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentlySelectedDay = ref.watch(selectedDayProvider);
    return Expanded(
      child: FutureBuilder(
    future: getBirds(currentlySelectedDay),
    builder:(context, AsyncSnapshot<List<Bird>> snapshot) {
        if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
         } else {
            return Container(
                child: ListView.builder(    
                    padding: const EdgeInsets.all(15),                                              
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                        return BirdCard(bird:snapshot.data![index]);                                           
                    }
                )
            );
         }
     }
)
    );
  }
}

class BirdCard extends StatelessWidget {
  const BirdCard({Key? key, required this.bird}) : super(key: key);
  final Bird bird;
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
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorGolden.withOpacity(0.4)),
              width: MediaQuery.of(context).size.width * 0.16,
              height: MediaQuery.of(context).size.width * 0.16,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.dove,
                  color: randomColor(),
                  size: MediaQuery.of(context).size.width * 0.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Text(bird.name), Text(bird.latinName)],
              ),
            )
          ],
        ),
      ),
    );
  }
}
