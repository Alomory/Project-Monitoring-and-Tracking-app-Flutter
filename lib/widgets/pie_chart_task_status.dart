import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:project_monitoring_and_tracking/models/project.dart';
import 'package:project_monitoring_and_tracking/models/task.dart';

class PieChartTaskStatus extends StatefulWidget {
  final Project project;
  const PieChartTaskStatus({super.key, required this.project});

  @override
  State<PieChartTaskStatus> createState() => _PieChartTaskStatusState();
}

class _PieChartTaskStatusState extends State<PieChartTaskStatus> {
  Map<String, double> mydata = {};


  double inProgress = 0, notStarted = 0 , completed = 0;



  void initData(){
    for (var phase in widget.project.phase) {
      for(var task in phase.tasks){
        if(task.taskStatus == TaskStatus.notStarted.index){
          notStarted+= 1;
        }else if(task.taskStatus == TaskStatus.inProgress.index){
          inProgress += 1;
        }else{
          completed +=1;
        }
      }
    }
    mydata = {
      "Not Started": notStarted,
      "In Progress": inProgress,
      "Completed" : completed
    };
  }
  @override
  void initState() {
    initData();
   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: PieChart(
        dataMap: mydata,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 50,
        // chartRadius: MediaQuery.of(context).size.width / 2,
        // initialAngleInDegree: 90,
        chartType: ChartType.ring,
        ringStrokeWidth: 20,
        centerText: "PROGRESS",
        legendOptions:  const LegendOptions(
          showLegendsInRow: true,
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
