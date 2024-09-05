import 'package:art_app/main_widgets/app_bar/widget/back_button/back_button.dart';
import 'package:flutter/material.dart';
import '../../const/app_color.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(
          "Kaydol",
          style: TextStyle(
            color: MainAppColors.mainAppBartxtcOLOR,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: MainAppColors.mainAppBarBackButton,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MainBackButton(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Default AppBar height
}

