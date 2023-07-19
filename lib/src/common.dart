
// import 'pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/homePage.dart';

Widget getHomePage(){
  return const HomePage();
}

showMainView(context){

  showModalBottomSheet(context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: (Radius.circular(10)),topRight: (Radius.circular(10)))),
      builder: (BuildContext context){
        return Container(
          height: 300,
          child: Center(child: Text('居中文字'),),
        );
      });
}