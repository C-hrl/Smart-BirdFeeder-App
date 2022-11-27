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
  final String latinName;
  final int count;
  final Color color;
  final double meanTemperature;
  final double meanHumidity;
  final double meanPressure;

  BirdData(this.name, this.latinName, this.count, this.color, this.meanTemperature, this.meanHumidity, this.meanPressure);
}

List<BirdData> chartDatabase = List.empty();

final chardataProvider = StateProvider<List<BirdData>>((ref) {
  return chartDatabase;
});

final chartIndexProvider = StateProvider<int>((ref) {
  return -1;
});

class Stats extends ConsumerWidget {
  const Stats({Key? key}) : super(key: key);

  Map<String,BirdData> mapDataPerName(List<Bird> birds) {
    Map<String, List<num>> dataPerName = {};
    Map<String, String> latinPerName = {};
    for (var bird in birds) {
      //setup
      dataPerName.putIfAbsent(bird.name, () => [0,0.0,0.0,0.0]);
      latinPerName.putIfAbsent(bird.name, () => bird.latinName);

      //increment
      dataPerName[bird.name]![0] += 1; //count
      dataPerName[bird.name]![1] += bird.temperature; //temperature
      dataPerName[bird.name]![2] += bird.humidity; //humidity
      dataPerName[bird.name]![3] += bird.pressure; //pressure
    }
    return dataPerName.map((name, data) {
      int count = data[0] as int;
      return MapEntry(name,BirdData(name, latinPerName[name]!, count, harmonizedRandomColor(seed: name.hashCode), data[1]/count, data[2]/count, data[3]/count)); //mean calculation
    });
  }

  Map<String,BirdData> buildChart(WidgetRef ref, DateTime startDate, int offset) {
    List<Bird> birdsThisDay =
        getBirds(ref, startDate.add(Duration(days: offset)));
    return mapDataPerName(birdsThisDay);
  }

  Map<String,BirdData> buildChartFromRange(
      WidgetRef ref, DateTime startDate, DateTime endDate) {
    List<Bird> birdsThisRange = List.empty(growable: true);
    var offset = 0;
    while (offset < endDate.difference(startDate).inDays + 1) {
      birdsThisRange.addAll(getBirds(ref, startDate.add(Duration(days: offset))));
      offset += 1;
    }

    return mapDataPerName(birdsThisRange);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartdata = ref.watch(chardataProvider);
    final selectedIndex =  ref.watch(chartIndexProvider);
    final currentSelectedChart = chartdata.isNotEmpty && selectedIndex >= 0 ? chartdata[selectedIndex] : null; //null if nothing selected or no data
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
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: (args) {
              Map<String,BirdData> newChartdata = {};
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
              ref.watch(chardataProvider.notifier).state = newChartdata.values.toList();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SfCircularChart(
            legend: Legend(
                isVisible: true,
                iconWidth: 12,
                textStyle: subtitleText,
                orientation: LegendItemOrientation.vertical,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap),
            series: [
              DoughnutSeries<BirdData, String>(
                
                onPointTap: (pointInteractionDetails) {
                  var tapIndex = pointInteractionDetails.pointIndex;
                  if(tapIndex!=null && tapIndex!=selectedIndex) {
                    ref.watch(chartIndexProvider.notifier).state = tapIndex;
                  } else if(tapIndex==selectedIndex) {
                    ref.watch(chartIndexProvider.notifier).state = -1; //no selection
                  }
                },
                  dataSource: chartdata,
                  xValueMapper: (BirdData data, _) => data.name,
                  yValueMapper: (BirdData data, _) => data.count,
                  pointColorMapper: (BirdData data, _) => data.color,
                  dataLabelMapper: (BirdData data, _) => data.name,
                  radius: '100%',
                  innerRadius: '40%',
                  explode: true,
                  enableTooltip: true,
                  explodeIndex: selectedIndex,
                  dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      color: colorBlue,
                      labelPosition: ChartDataLabelPosition.outside))
            ],
          ),
        ),
        if(currentSelectedChart != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(children: [
            Text(
              currentSelectedChart.name,
              style: titleText,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentSelectedChart.latinName,
                style: subtitleText,
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BirdInfo(
                      cardTitle: "Nombre Total de ${currentSelectedChart.name}s",
                      data: "${currentSelectedChart.count}",
                      icon: FontAwesomeIcons.crow),
                  BirdInfo(
                    cardTitle: "Température moyenne",
                    data: "${currentSelectedChart.meanTemperature} °C",
                    icon: FontAwesomeIcons.temperatureHalf,
                  )
                ]),
            Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.01)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BirdInfo(
                  cardTitle: "Pression Moyenne",
                  data: "${currentSelectedChart.meanPressure} kPa",
                  icon: FontAwesomeIcons.gauge,
                ),
                BirdInfo(
                    cardTitle: "Humidité Moyenne",
                    data: "${currentSelectedChart.meanHumidity} %",
                    icon: FontAwesomeIcons.droplet)
              ],
            )
          ]),
        )],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
