import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_bird_feeder/database/db.dart';
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
    DateRangePickerController _controller = DateRangePickerController();
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfDateRangePicker(
                controller: _controller,
                onSelectionChanged: (date) {
                  ref.watch(selectedDayProvider.notifier).state = date.value;
                },
                cellBuilder: (BuildContext context,
                    DateRangePickerCellDetails cellDetails) {
                  if (_controller.view == DateRangePickerView.month) {
                    return Center(
                      child: Stack(
                        children: [
                          Container(
                            width: cellDetails.bounds.width * 0.92,
                            height: cellDetails.bounds.height * 0.92,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _controller.selectedDate ==
                                      cellDetails.date
                                  ? colorBlue
                                  : /*cellDetails.date.day == DateTime.now().day ? colorBlue.withOpacity(0.5) :*/ null,
                              border: cellDetails.date.day == DateTime.now().day
                                  ? Border.all(width: 1, color: colorBlue)
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cellDetails.date.day.toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: cellDetails.date ==
                                          _controller.selectedDate
                                      ? Colors.white
                                      : cellDetails.date.day ==
                                              DateTime.now().day
                                          ? colorBlue
                                          : null),
                            ),
                          ),
                          Positioned(
                              bottom: cellDetails.bounds.height * 0.01,
                              right: cellDetails.bounds.width * 0.1,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: colorGolden,
                                ),
                                child: Text(
                                  '5', //won't be const in the future
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: 9, color: colorWhite),
                                ),
                              ))
                        ],
                      ),
                    );
                  } else if (_controller.view == DateRangePickerView.year) {
                    return Container(
                      width: cellDetails.bounds.width,
                      height: cellDetails.bounds.height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _controller.selectedDate == cellDetails.date
                            ? colorBlue
                            : cellDetails.date.month == DateTime.now().month
                                ? colorBlue.withOpacity(0.5)
                                : null,
                        shape: BoxShape.circle,
                      ),
                      child: Text(cellDetails.date.month.toString()),
                    );
                  } else if (_controller.view == DateRangePickerView.decade) {
                    return Container(
                      width: cellDetails.bounds.width,
                      height: cellDetails.bounds.height,
                      alignment: Alignment.center,
                      child: Text(cellDetails.date.year.toString()),
                    );
                  } else {
                    final int yearValue = (cellDetails.date.year ~/ 10) * 10;
                    return Container(
                      width: cellDetails.bounds.width,
                      height: cellDetails.bounds.height,
                      alignment: Alignment.center,
                      child: Text(yearValue.toString() +
                          ' - ' +
                          (yearValue + 9).toString()),
                    );
                  }
                },
                monthCellStyle: const DateRangePickerMonthCellStyle(
                    cellDecoration: BoxDecoration(color: Colors.transparent)),
                selectionColor: Colors.white.withOpacity(0.0),
                todayHighlightColor: colorBlue,
                headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center, textStyle: calendarTitle),
                selectionTextStyle: calendarText,
              ),
            ),
            const BirdList()
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
    return Flexible(
        fit: FlexFit.loose,
        child: FutureBuilder(
            future: getBirds(currentlySelectedDay),
            builder: (context, AsyncSnapshot<List<Bird>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Column(
                    children: snapshot.data!
                        .map((bird) => BirdCard(bird: bird))
                        .toList());
              }
            }));
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
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    //Temperature
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.temperatureHalf,
                          color: Colors.red,
                        ),
                        Text("${bird.temperature} °C")
                      ],
                    ),
                  ),
                  Padding(
                    //Humidity
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.droplet,
                          color: Colors.lightBlue,
                        ),
                        Text("${bird.humidity} %")
                      ],
                    ),
                  ),
                  Padding(
                    //Pressure
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.weightHanging,
                          color: Colors.grey,
                        ),
                        Text("${bird.pressure} %")
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
