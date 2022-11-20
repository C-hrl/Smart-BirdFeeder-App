import 'package:flutter/material.dart';
import 'package:smart_bird_feeder/theme/theme.dart';
import 'package:smart_bird_feeder/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ChartData {
  final String name;
  final int number;
  final Color color;

  ChartData(this.name, this.number, this.color);
}

class Stats extends StatelessWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chardata = [
      ChartData("Mésange", 47, randomColor()),
      ChartData("Rouge-Gorge", 32, randomColor()),
      ChartData("Pie", 12, randomColor()),
      ChartData("Jay", 24, randomColor()),
      ChartData("Moineau", 560, randomColor()),
    ];
    return Expanded(
        child: SingleChildScrollView(
      child: Column(children: [
        SfDateRangePicker(
          view: DateRangePickerView.month,
          viewSpacing: 10,
          selectionMode: DateRangePickerSelectionMode.extendableRange,
        ),
        SfCircularChart(
          legend: Legend(
              isVisible: true,
              iconWidth: 10,
              orientation: LegendItemOrientation.vertical,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap),
          series: [
            DoughnutSeries<ChartData, String>(
                dataSource: chardata,
                xValueMapper: (ChartData data, _) => data.name,
                yValueMapper: (ChartData data, _) => data.number,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelMapper: (ChartData data, _) => data.name,
                radius: '90%',
                innerRadius: '50%',
                explode: true,
                explodeIndex: 0,
                strokeColor: colorWhite,
                strokeWidth: 1,
                enableTooltip: true,
                dataLabelSettings: const DataLabelSettings(isVisible: true))
          ],
        )
      ]),
    ));
  }
}
