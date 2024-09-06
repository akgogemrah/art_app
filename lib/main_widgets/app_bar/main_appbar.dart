import 'package:art_app/main_widgets/app_bar/widget/back_button/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import '../../const/app_color.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isbackButton;
  final String title;

  MainAppbar({
    required this.title,
    required this.isbackButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: isbackButton ? NavigationToolbar.kMiddleSpacing : 0.0, // Adjust title spacing based on back button presence
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: MainAppColors.mainAppBartxtcOLOR,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: MainAppColors.mainAppBarBackButton,
      leading: isbackButton ? MainBackButton() : Icon(FontAwesomeIcons.artstation

        ,color: Colors.white,), // Use SizedBox.shrink() for no space when no button
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);  // Default AppBar height
}
