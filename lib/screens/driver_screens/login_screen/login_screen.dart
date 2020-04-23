import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/utilities/styles/main_theme_styles.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:bot_toast/bot_toast.dart';

import 'local_widgets/login_button.dart';

class LoginScreen extends StatefulWidget {
  static final routeName = 'loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool waitingAuthResponse;
  DriverMTOAuthProvider authProvider;

  //initializing values
  @override
  void didChangeDependencies() {
    waitingAuthResponse = false;
    this.authProvider = Provider.of<DriverMTOAuthProvider>(context);
    SizeConfig().init(context);
    super.didChangeDependencies();
  }

  void _showErrorDialog(BuildContext context) {
    BotToast.showText(
      text: "Coudn't Authenticate You! Please Try again",
      textStyle: GoogleFonts.poppins(
        textStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );

    Logger().wtf("couldnt Auth : ");
  }

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (mounted) {
        setState(() {
          waitingAuthResponse = true;
        });
      }
      authProvider.login().then((result) {
        if (!result) {
          _showErrorDialog(context);
          if (mounted) {
            setState(() {
              waitingAuthResponse = false;
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            height: SizeConfig.safeBlockVertical * 80,
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      // bottom: (SizeConfig.screenHeight * 0.05),
                      top: (SizeConfig.screenHeight * 0.1)),
                  child: Center(
                    child: Text(
                      "My Taxi Office",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: SizeConfig.textSize * 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text(
                      "Mobile Version",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: SizeConfig.textSize * 4,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 8,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          initialValue: authProvider.badgeIdInput,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w300),
                          decoration: Style.formInputDecoration("Badge ID"),
                          validator: (v) {
                            if (v.trim().isEmpty) {
                              return "this field cannot be empty!";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (v) {
                            authProvider.badgeIdInput = v;
                          },
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),
                        TextFormField(
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w300),
                          obscureText: true,
                          decoration: Style.formInputDecoration("Password"),
                          validator: (v) {
                            if (v.isEmpty) {
                              return "this field cannot be empty!";
                            } else if (v.length < 6) {
                              return "Password cannot have less than 6 characters!";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (v) {
                            authProvider.passwordInput = v;
                          },
                        ),
                      ],
                    )),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 6,
                ),
                waitingAuthResponse
                    ? Center(child: CircularProgressIndicator())
                    : LoginButton(
                        screenContext: context,
                        text: 'Log In',
                        onTap: _submit,
                      ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          height: SizeConfig.blockSizeVertical * 0.8,
        ),
      ),
    );
  }
}
