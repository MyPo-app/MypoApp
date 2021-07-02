import 'package:flutter/material.dart';
import 'package:mypo/pages/home_page.dart';

/*
    -that class creates the logo in the middle
*/
class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
          color: d_lightgray,
          image: DecorationImage(image: AssetImage('images/logo.png'))),
    );
  }
}