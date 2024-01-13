
import 'package:flutter/material.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartWidget extends StatefulWidget {
  final Project project;
  const PieChartWidget({super.key, required this.project});
  @override
  State<PieChartWidget> createState() => _PieChartState();
}
class _PieChartState extends State<PieChartWidget> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),

      child: PieChart(
          dataMap: widget.project.tasksPerPhase,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 50,
        // chartRadius: MediaQuery.of(context).size.width / 2,
        // initialAngleInDegree: 90,

        chartType: ChartType.ring,
        ringStrokeWidth: 20,
        centerText: "PHASES",
        legendOptions:  const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.bottom,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(

          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: true,
          decimalPlaces: 1,
        ),


      ),
    );
  }
}
