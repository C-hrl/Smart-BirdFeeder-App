import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
      child: Stack(children: [
        SingleChildScrollView(
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
                      var isToday = DateUtils.dateOnly(cellDetails.date) ==
                          DateUtils.dateOnly(DateTime.now());
                      return Center(
                        child: Stack(
                          children: [
                            Container(
                              width: cellDetails.bounds.width * 0.92,
                              height: cellDetails.bounds.height * 0.92,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    _controller.selectedDate == cellDetails.date
                                        ? colorBlue.withOpacity(0.6)
                                        : null,
                                border: isToday &&
                                        cellDetails.date !=
                                            _controller.selectedDate
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
                                        : isToday
                                            ? colorBlue
                                            : null),
                              ),
                            ),
                            DisplayNumberOfBirdPerDay(
                              cellData: cellDetails,
                            )
                          ],
                        ),
                      );
                    } else if (_controller.view == DateRangePickerView.year) {
                      return Container(
                        width: cellDetails.bounds.width,
                        height: cellDetails.bounds.height,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: _controller.selectedDate == cellDetails.date
                              ? colorBlue
                              : cellDetails.date == DateTime.now()
                                  ? colorBlue.withOpacity(0.6)
                                  : null,
                          border:
                              (cellDetails.date.month == DateTime.now().month)
                                  ? Border.all(width: 1, color: colorBlue)
                                  : null,
                        ),
                        child: Text(DateFormat.MMM().format(cellDetails.date)),
                      );
                    } else if (_controller.view == DateRangePickerView.decade) {
                      return Container(
                        width: cellDetails.bounds.width,
                        height: cellDetails.bounds.height,
                        alignment: Alignment.center,
                        child: Text(cellDetails.date.year.toString()),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: _controller.selectedDate == cellDetails.date
                              ? colorBlue
                              : cellDetails.date == DateTime.now()
                                  ? colorBlue.withOpacity(0.6)
                                  : null,
                          border: (cellDetails.date.year == DateTime.now().year)
                              ? Border.all(width: 1, color: colorBlue)
                              : null,
                        ),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: _controller.selectedDate == cellDetails.date
                              ? colorBlue
                              : cellDetails.date == DateTime.now()
                                  ? colorBlue.withOpacity(0.6)
                                  : null,
                          border: (yearValue == DateTime.now().year ~/ 10 * 10)
                              ? Border.all(width: 1, color: colorBlue)
                              : null,
                        ),
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
        const AudioPlayer()
      ]),
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
        child: Column(
            children: getBirds(ref, currentlySelectedDay)
                .map((bird) => BirdCard(bird: bird))
                .toList()));
  }
}

class BirdCard extends StatelessWidget {
  const BirdCard({Key? key, required this.bird}) : super(key: key);
  final Bird bird;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.18,
        child: Card(
          color: colorGolden.withOpacity(0.1),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorGolden.withOpacity(0.95)),
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.width * 0.16,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.dove,
                    color: harmonizedRandomColor(seed: bird.name.hashCode),
                    size: MediaQuery.of(context).size.width * 0.1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      bird.name,
                      style: titleText,
                    ),
                    Text(bird.latinName, style: subtitleText)
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${bird.date.hour} : ${bird.date.minute}",
                  style: text.copyWith(color: colorGolden),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayNumberOfBirdPerDay extends ConsumerWidget {
  const DisplayNumberOfBirdPerDay({Key? key, required this.cellData})
      : super(key: key);
  final DateRangePickerCellDetails cellData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Bird> birds = getBirds(ref, cellData.date);
    if (birds.isNotEmpty) {
      return Positioned(
          bottom: cellData.bounds.height * 0.01,
          right: cellData.bounds.width * 0.1,
          child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: colorGolden,
              ),
              child: Text(
                birds.length.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: colorWhite),
              )));
    }
    return const SizedBox.shrink();
  }
}

class AudioPlayer extends ConsumerWidget {
  const AudioPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: colorBlue,
          height: 140,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.play))
              ],
            ),
            AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width, 70),
                playerController: PlayerController())
          ]),
        ),
      ],
    );
  }
}
