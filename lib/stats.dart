import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_bird_feeder/database/db.dart';
import 'package:smart_bird_feeder/theme/styles.dart';
import 'package:smart_bird_feeder/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ChartData {
  final String name;
  final int number;
  final Color color;

  ChartData(this.name, this.number, this.color);
}

List<ChartData> chardata = List.empty()/* [
      ChartData("Mésange", 47, randomColor()),
      ChartData("Rouge-Gorge", 32, randomColor()),
      ChartData("Pie", 12, randomColor()),
      ChartData("Jay", 24, randomColor()),
      ChartData("Moineau", 50, randomColor()),
    ]*/;
final chardataProvider = StateProvider<List<ChartData>>((ref) {
  return chardata;
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

  List<ChartData> buildChart(WidgetRef ref, DateTime startDate, int offset) {
    List<ChartData> newChartdata = List.empty(growable: true);
    List<Bird> birdsThisDay = getBirds(ref, startDate.add(Duration(days: offset)));
    var birdsCount = countBirds(birdsThisDay);
    birdsCount.forEach((name, count) { 
      newChartdata.add(ChartData(name, count, randomColor(seed: name.hashCode)));
    });
    return newChartdata;
  }

  List<ChartData> buildChartFromRange(WidgetRef ref, DateTime startDate, DateTime endDate) {
    List<ChartData> newChartdata = List.empty(growable: true);
    var offset = 0;
    while(offset < endDate.difference(startDate).inDays+1) {
      newChartdata.addAll(buildChart(ref, startDate, offset));
      offset+=1;
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
              List<ChartData> newChartdata = List.empty(growable: true);
              if (args.value is PickerDateRange) { //fine
                final rangeStartDate = args.value.startDate;
                final rangeEndDate = args.value.endDate;
                if(rangeStartDate != null && rangeEndDate != null) {
                  newChartdata = buildChartFromRange(ref, rangeStartDate, rangeEndDate);
                }
              } else if (args.value is DateTime) { //fine, unused
                final DateTime selectedDate = args.value;
                newChartdata = buildChart(ref, selectedDate, 0);
              } else if (args.value is List<DateTime>) { // buggy, unused
                final List<DateTime> selectedDates = args.value;
                for(var date in selectedDates) {
                  newChartdata = buildChart(ref, date, 0);
                }
              } else { //buggy, unused
                final List<PickerDateRange> selectedRanges = args.value;
                for(var dateRange in selectedRanges) {
                  if(dateRange.startDate != null && dateRange.endDate != null) {
                    newChartdata.addAll(buildChartFromRange(ref, dateRange.startDate!, dateRange.endDate!));
                  }
                }
              }
              ref.watch(chardataProvider.notifier).state = newChartdata;
            },
          ),
        ),
        SfCircularChart(
          onSelectionChanged: (selectionArgs) {},
          legend: Legend(
              isVisible: true,
              iconWidth: 10,
              orientation: LegendItemOrientation.vertical,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap),
          series: [
            DoughnutSeries<ChartData, String>(
              dataSource: chartdata,
              xValueMapper: (ChartData data, _) => data.name,
              yValueMapper: (ChartData data, _) => data.number,
              pointColorMapper: (ChartData data, _) => data.color,
              dataLabelMapper: (ChartData data, _) => data.name,
              radius: '90%',
              innerRadius: '40%',
              explode: true,
              explodeIndex: 0,
              enableTooltip: true,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        )
      ]),
    ));
  }
}
