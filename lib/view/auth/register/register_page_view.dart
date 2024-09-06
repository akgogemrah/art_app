import 'package:art_app/const/app_color.dart';
import 'package:art_app/service/authantication/auth_service.dart';
import 'package:art_app/service/database/add_user.dart';
import 'package:art_app/view/auth/login/widget/auth_texttfield/auth_textfield.dart';
import 'package:art_app/view/auth/widget/e_mail_auth_button.dart';
import 'package:art_app/view/auth/widget/social_auth_button.dart';
import 'package:art_app/view/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

import '../../../main_widgets/app_bar/main_appbar.dart';
import '../../../util/animation/fade_page_route.dart';
import '../login/login_page_view.dart';

class RegisterPageView extends StatefulWidget {
  const RegisterPageView({super.key});

  @override
  State<RegisterPageView> createState() => _RegisterPageViewState();
}

class _RegisterPageViewState extends State<RegisterPageView> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emainController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isloading = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MainAppColors.mainAppBarBackButton,
      appBar: MainAppbar(isbackButton: true, title: 'Kaydol',),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.08),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Google yada Apple hesabınla giriş yapabilirsin",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SocialAuthButton(icon: FontAwesomeIcons.google),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SocialAuthButton(icon: FontAwesomeIcons.apple),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Align(alignment: Alignment.topLeft, child: Text("Ad", style: _textFieldLabelStyle())),
                  SizedBox(height: 8),
                  AuthTextField(controller: _nameController),
                  SizedBox(height: 15),
                  Align(alignment: Alignment.topLeft, child: Text("Email", style: _textFieldLabelStyle())),
                  SizedBox(height: 4),
                  AuthTextField(controller: _emainController),
                  SizedBox(height: 15),
                  Align(alignment: Alignment.topLeft, child: Text("Şifre", style: _textFieldLabelStyle())),
                  SizedBox(height: 4),
                  AuthTextField(obscureText: true, controller: _passwordController),
                  SizedBox(height: screenSize.height * 0.03),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isloading = true;
                      });
                      await AuthService().createUserWithEmailAndPassword(
                          context, _emainController.text, _passwordController.text);
                      setState(() {
                        _isloading = false;
                      });
                      await  AddUser().emailUser(_emainController.text, _nameController.text);
                      Navigator.of(context).push(
                        FadePageRoute(page: HomePage()),
                      );
                    },
                    child: EmailAuthButton(text: "Kayıt Ol"),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        FadePageRoute(page: LoginPageView()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hesabın Var mı? ", style: TextStyle(color: Colors.white70)),
                        Text("Giriş Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isloading)
            Container(
              color: Colors.black45, // Yarı şeffaf bir arka plan
              child: Center(
                child: CircularProgressIndicator(), // Yükleniyor ikonu
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _textFieldLabelStyle() => TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w700);
}
