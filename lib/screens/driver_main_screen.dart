import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';

import 'driver_screens/Profile/driver_profile_screen.dart';
import 'driver_screens/chilliwack_taxi_radio/chilliwack_taxi_radio_screen.dart';

class DriverMainScreen extends StatefulWidget {
  static final routeName = 'driverMainScreen';
  final titles = ['Chilliwack Taxi Radio', 'Profile'];
  final colors = [Colors.red, Colors.cyan];
  final icons = [CupertinoIcons.mic, CupertinoIcons.profile_circled];

  DriverMainScreen({Key key}) : super(key: key);

  @override
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  PageController _pageController;
  MenuPositionController _menuPositionController;
  bool userPageDragging = false;

  @override
  void initState() {
    _menuPositionController = MenuPositionController(initPosition: 0);

    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);

    super.initState();
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  void checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle) {
      userPageDragging = true;
    } else if (scrollNotification is ScrollEndNotification) {
      userPageDragging = false;
    }
    if (userPageDragging) {
      _menuPositionController.findNearestTarget(_pageController.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            checkUserDragging(scrollNotification);
            return true;
          },
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (page) {},
            children: <Widget>[
              ChilliwackTaxiRadioScreen(),
              DriverProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: BubbledNavigationBar(
          controller: _menuPositionController,
          initialIndex: 0,
          itemMargin: EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: Colors.white,
          defaultBubbleColor: Colors.blue,
          onTap: (index) {
            _pageController.animateToPage(index,
                curve: Curves.easeIn, duration: Duration(milliseconds: 500));
          },
          items: widget.titles.map((title) {
            var index = widget.titles.indexOf(title);
            var color = widget.colors[index];
            return BubbledNavigationBarItem(
              icon: getIcon(index, color),
              activeIcon: getIcon(index, Colors.white),
              bubbleColor: color,
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
        ));
  }

  Padding getIcon(int index, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Icon(widget.icons[index], size: 30, color: color),
    );
  }
}
