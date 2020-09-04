import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  Loading(this.msg);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  msg,
                  style: TextStyle(fontSize: 1000),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SpinKitCubeGrid(
              color: Colors.blue,
              size: 100,
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}