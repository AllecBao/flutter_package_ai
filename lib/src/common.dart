
// import 'pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/homePage.dart';
import 'views/homeView.dart';

showMainView(context){

  showModalBottomSheet(context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: (Radius.circular(10)),topRight: (Radius.circular(10)))),
      builder: (BuildContext context){
        return const HomeView();
      });
}