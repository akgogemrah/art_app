import 'package:art_app/const/app_color.dart';
import 'package:art_app/service/authantication/auth_service.dart';
import 'package:art_app/view/auth/login/widget/auth_texttfield/auth_textfield.dart';
import 'package:art_app/view/auth/register/register_page_view.dart';
import 'package:art_app/view/auth/widget/e_mail_auth_button.dart';
import 'package:art_app/view/auth/widget/social_auth_button.dart';
import 'package:art_app/view/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

import '../../../main_widgets/app_bar/main_appbar.dart';
import '../../../util/animation/fade_page_route.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MainAppColors.mainAppBarBackButton,
      appBar: MainAppbar(isbackButton: true,title: "Giriş Yap",),
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
                  Align(alignment: Alignment.topLeft, child: Text("Email", style: _textFieldLabelStyle())),
                  SizedBox(height: 4),
                  AuthTextField(controller: _emailController),
                  SizedBox(height: 15),
                  Align(alignment: Alignment.topLeft, child: Text("Şifre", style: _textFieldLabelStyle())),
                  SizedBox(height: 4),
                  AuthTextField(obscureText: true, controller: _passwordController),
                  SizedBox(height: screenSize.height * 0.03),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await AuthService().signInWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text);
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).push(
                        FadePageRoute(page: HomePage()),
                      );
                    },
                    child: EmailAuthButton(text: "Giriş Yap"),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        FadePageRoute(page: RegisterPageView()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hesabın Yok mu? ", style: TextStyle(color: Colors.white70)),
                        Text("Kayıt Ol", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _textFieldLabelStyle() => TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w700);
}
