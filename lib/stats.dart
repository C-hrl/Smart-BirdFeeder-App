import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_bird_feeder/database/db.dart';
import 'package:smart_bird_feeder/theme/styles.dart';
import 'package:smart_bird_feeder/theme/theme.dart';
import 'package:smart_bird_feeder/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BirdData {
  final String name;
  final int count;
  final Color color;

  BirdData(this.name, this.count, this.color);
}

List<BirdData> chartDatabase =
    List.empty() /* [
      ChartData("Mésange", 47, randomColor()),
      ChartData("Rouge-Gorge", 32, randomColor()),
      ChartData("Pie", 12, randomColor()),
      ChartData("Jay", 24, randomColor()),
      ChartData("Moineau", 50, randomColor()),
    ]*/
    ;
final chardataProvider = StateProvider<List<BirdData>>((ref) {
  return chartDatabase;
});

class Stats extends ConsumerWidget {
  const Stats({Key? key}) : super(key: key);

  Map<String, int> countBirds(List<Bird> birds) {
    Map<String, int> countPerName = {};
    for (var bird in birds) {
      countPerName.putIfAbsent(bird.name, () => 0);
      countPerName[bird.name] = countPerName[bird.name]! + 1;
    }
    return countPerName;
  }

  List<BirdData> buildChart(WidgetRef ref, DateTime startDate, int offset) {
    List<BirdData> newChartDatabase = List.empty(growable: true);
    List<Bird> birdsThisDay =
        getBirds(ref, startDate.add(Duration(days: offset)));
    var birdsCount = countBirds(birdsThisDay);
    birdsCount.forEach((name, count) {
      newChartDatabase.add(
          BirdData(name, count, harmonizedRandomColor(seed: name.hashCode)));
    });
    return newChartDatabase;
  }

  List<BirdData> buildChartFromRange(
      WidgetRef ref, DateTime startDate, DateTime endDate) {
    List<BirdData> newChartdata = List.empty(growable: true);
    var offset = 0;
    while (offset < endDate.difference(startDate).inDays + 1) {
      newChartdata.addAll(buildChart(ref, startDate, offset));
      offset += 1;
    }
    return newChartdata;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartdata = ref.watch(chardataProvider);
    return Expanded(
        child: SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SfDateRangePicker(
            headerStyle: DateRangePickerHeaderStyle(
                textAlign: TextAlign.center, textStyle: calendarTitle),
            view: DateRangePickerView.month,
            viewSpacing: 10,
            selectionMode: DateRangePickerSelectionMode.extendableRange,
            onSelectionChanged: (args) {
              List<BirdData> newChartdata = List.empty(growable: true);
              if (args.value is PickerDateRange) {
                //fine
                final rangeStartDate = args.value.startDate;
                final rangeEndDate = args.value.endDate;
                if (rangeStartDate != null && rangeEndDate != null) {
                  newChartdata =
                      buildChartFromRange(ref, rangeStartDate, rangeEndDate);
                }
              } else if (args.value is DateTime) {
                //fine, unused
                final DateTime selectedDate = args.value;
                newChartdata = buildChart(ref, selectedDate, 0);
              } else if (args.value is List<DateTime>) {
                // buggy, unused
                final List<DateTime> selectedDates = args.value;
                for (var date in selectedDates) {
                  newChartdata = buildChart(ref, date, 0);
                }
              } else {
                //buggy, unused
                final List<PickerDateRange> selectedRanges = args.value;
                for (var dateRange in selectedRanges) {
                  if (dateRange.startDate != null &&
                      dateRange.endDate != null) {
                    newChartdata.addAll(buildChartFromRange(
                        ref, dateRange.startDate!, dateRange.endDate!));
                  }
                }
              }
              ref.watch(chardataProvider.notifier).state = newChartdata;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SfCircularChart(
            onSelectionChanged: (selectionArgs) {},
            legend: Legend(
                isVisible: true,
                iconWidth: 10,
                textStyle: subtitleText,
                orientation: LegendItemOrientation.vertical,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap),
            series: [
              DoughnutSeries<BirdData, String>(
                  dataSource: chartdata,
                  xValueMapper: (BirdData data, _) => data.name,
                  yValueMapper: (BirdData data, _) => data.count,
                  pointColorMapper: (BirdData data, _) => data.color,
                  dataLabelMapper: (BirdData data, _) => data.name,
                  radius: '115%',
                  innerRadius: '40%',
                  explode: true,
                  enableTooltip: true,
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      color: colorBlue,
                      labelPosition: ChartDataLabelPosition.outside))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(children: [
            Text(
              "BirdName",
              style: titleText,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "LatinName",
                style: subtitleText,
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  BirdInfo(
                      cardTitle: "Nombre Total de ${55}s",
                      data: "${57}",
                      icon: FontAwesomeIcons.crow),
                  BirdInfo(
                    cardTitle: "Température moyenne",
                    data: "${5} °C",
                    icon: FontAwesomeIcons.temperatureHalf,
                  )
                ]),
            Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                BirdInfo(
                  cardTitle: "Pression Moyenne",
                  data: "${150} kPa",
                  icon: FontAwesomeIcons.gauge,
                ),
                BirdInfo(
                    cardTitle: "Humidité Moyenne",
                    data: "${80} %",
                    icon: FontAwesomeIcons.droplet)
              ],
            )
          ]),
        ),
      ]),
    ));
  }
}

class BirdInfo extends StatelessWidget {
  const BirdInfo(
      {Key? key,
      required this.data,
      required this.icon,
      required this.cardTitle})
      : super(key: key);
  final String cardTitle;
  final String data;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: colorBlue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "$cardTitle\n",
                  style: lightText.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    FaIcon(
                      icon,
                      color: colorGolden,
                      size: MediaQuery.of(context).size.width * 0.07,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        data,
                        style: lightText.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
