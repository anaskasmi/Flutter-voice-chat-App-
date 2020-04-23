import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/providers/driver_providers/audioRecorderProvider.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/providers/driver_providers/voiceMessagesProvider.dart';
import 'package:my_project_name/screens/driver_main_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'screens/driver_screens/login_screen/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DriverMTOAuthProvider()),
        ChangeNotifierProvider.value(value: VoiceMessagesProvider()),
        ChangeNotifierProvider.value(value: AudioRecordProvider()),
      ],
      child: Consumer<DriverMTOAuthProvider>(
        builder: (ctx, authProvider, _) {
          // auth.autoLogin();

          return BotToastInit(
            child: MaterialApp(
              navigatorObservers: [
                BotToastNavigatorObserver()
              ], //toast listener
              home: authProvider.isAuth
                  ? DriverMainScreen()
                  : FutureBuilder(
                      future: authProvider.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : LoginScreen(),
                    ),

              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
