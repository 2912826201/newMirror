import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EchartsView extends StatefulWidget {
  @override
  EchartsViewState createState() => EchartsViewState();

}
class EchartsViewState extends State<EchartsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("图表"),),
      body: Container(
    //     child: Echarts(
    //       option:
    // {
    //   xAxis: {
    //     type: 'category',
    //     data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    //   },
    //   yAxis: {
    //     type: 'value'
    //   },
    //   series: [{
    //     data: [820, 932, 901, 934, 1290, 1330, 1320],
    //     type: 'line'
    //   }]
    // },
    //     )
      ),
    );
  }

}