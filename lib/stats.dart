import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      ChartData("Mésange", 47, Colors.blue),
      ChartData("Rouge-Gorge", 32, Colors.red),
      ChartData("Pie", 12, Colors.blueGrey),
      ChartData("Jay", 24, Colors.green),
      ChartData("Moineau", 560, Colors.brown)
    ];
    return Expanded(
        child: Column(children: [
      SfCircularChart(
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
              dataLabelSettings: const DataLabelSettings(isVisible: true))
        ],
      )
    ]));
  }
}
