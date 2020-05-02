import 'package:flutter/material.dart';
import 'package:my_project_name/models/driver.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';

import 'local_widgets/profile_header.dart';

class DriverProfileScreen extends StatefulWidget {
  static final routeName = 'driverProfileScreen';

  @override
  _DriverProfileScreenState createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Driver currentDriver;
  DriverMTOAuthProvider authProvider;

  @override
  void didChangeDependencies() {
    //initializing authProvider
    this.authProvider ??= Provider.of<DriverMTOAuthProvider>(context);
    //initializing currentDriver
    if (currentDriver == null) {
      this.authProvider.currentDriver.then((result) {
        setState(() {
          currentDriver = result;
        });
      });
    }
    super.didChangeDependencies();
  }

  //logout function
  logout() {
    authProvider?.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: currentDriver == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                children: <Widget>[
                  ProfileHeader(currentDriver: currentDriver),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Badge ID'),
                              subtitle: currentDriver.badgeId != null
                                  ? Text(currentDriver.badgeId)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: const Text('License Number'),
                              subtitle: currentDriver.lisenceNumber != null
                                  ? Text(currentDriver.lisenceNumber)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: const Text('LICENSE CLASS'),
                              subtitle: currentDriver.licenseClass != null
                                  ? Text(currentDriver.licenseClass)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Home Phone'),
                              subtitle: currentDriver.homePhone != null
                                  ? Text(currentDriver.homePhone)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('EMAIL'),
                              subtitle: currentDriver.email != null
                                  ? Text(currentDriver.email)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.map),
                              title: const Text('Address'),
                              subtitle: currentDriver.address != null
                                  ? Text(currentDriver.address)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.today),
                              title: const Text('License Expiry'),
                              subtitle: currentDriver.licenseExpiry != null
                                  ? Text(currentDriver.licenseExpiry)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.today),
                              title: const Text('Permit Expiry'),
                              subtitle: currentDriver.permitExpiry != null
                                  ? Text(currentDriver.permitExpiry)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.today),
                              title: const Text('Abstract Expiry'),
                              subtitle: currentDriver.abstractExpiry != null
                                  ? Text(currentDriver.abstractExpiry)
                                  : Text(""),
                            ),
                            Divider(),
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: const Text('STATUS'),
                              subtitle: currentDriver.status != null
                                  ? Text(currentDriver.status.toUpperCase())
                                  : Text(""),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: SizeConfig.safeBlockVertical * 8,
                    width: SizeConfig.safeBlockHorizontal * 93,
                    child: RaisedButton(
                      onPressed: logout,
                      textColor: Colors.white,
                      color: Colors.cyan,
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        "Log Out",
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
