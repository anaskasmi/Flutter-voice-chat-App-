import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final Function onTap;
  final BuildContext screenContext;

  LoginButton({Key key, this.text, this.onTap, this.screenContext})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var size = SizeConfig();
    size.init(screenContext);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
          vertical: SizeConfig.blockSizeHorizontal * 4,
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(36, 173, 169, 2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(color: Colors.white70),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}
