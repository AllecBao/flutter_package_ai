
// import 'pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'pages/homePage.dart';
import 'views/homeView.dart';

showMainView(context){

  showModalBottomSheet(context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: (Radius.circular(10)),topRight: (Radius.circular(10)))),
      builder: (BuildContext context){
        return GestureDetector(
          onTap: (){
            if(Navigator.canPop(context)){
              Navigator.pop(context);
            }
          },
          child: Container(
            color: Color(0x00000001),
            child: Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: (){},
                child: HomeView(),
              ),
            ),
          ),
        );
      });
}