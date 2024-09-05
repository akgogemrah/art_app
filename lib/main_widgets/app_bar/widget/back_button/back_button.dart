import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../const/app_color.dart';

class MainBackButton extends StatelessWidget {
  const MainBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MainAppColors.mainAppBarBackButton,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MainAppColors.mainAppBartxtcOLOR,
        ),
      ),
      height: 80,
      width: 30,
      child: Icon(
        Icons.arrow_back_ios,
        color: MainAppColors.mainAppBartxtcOLOR,
      ),
    );
  }
}
