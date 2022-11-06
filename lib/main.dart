import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:smart_bird_feeder/styles.dart';
import 'package:smart_bird_feeder/theme.dart';
import 'package:table_calendar/table_calendar.dart';

final extendSidebar = StateProvider(((ref) => false));

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
      overlays: [SystemUiOverlay.top]);
  runApp(const SmartBirdFeederApp());
}

class SmartBirdFeederApp extends StatelessWidget {
  const SmartBirdFeederApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: colorGolendAccent,
              toolbarHeight: 0,
            ),
            body: Stack(
              children: [
                const MainScreen(),
                SideBar(
                    controller:
                        SidebarXController(selectedIndex: 0, extended: false))
              ],
            )));
  }
}

class SideBar extends StatelessWidget {
  const SideBar({Key? key, required SidebarXController controller})
      : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SidebarX(
        controller: _controller,
        theme: SidebarXTheme(
            decoration: sideBarColor,
            textStyle: text,
            selectedTextStyle: selectedText,
            itemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemTextPadding: const EdgeInsets.only(left: 30),
            selectedItemDecoration: sideBarSelectedItemBoxDecoration,
            iconTheme: iconTheme,
            selectedIconTheme: selectedIconTheme),
        extendedTheme: const SidebarXTheme(
          width: 150,
        ),
        headerBuilder: ((context, extended) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(colorGolden, BlendMode.multiply),
              child: Image.asset(
                "images/bird_icon.png",
              ),
            ),
          );
        }),
        headerDivider: Divider(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        items: const [
          SidebarXItem(icon: Icons.home, label: 'Home'),
          SidebarXItem(icon: Icons.calendar_month_rounded, label: "Calendar"),
          SidebarXItem(icon: Icons.calendar_month_rounded, label: "Calendar")
        ],
      ),
      if (true) ...[
        Expanded(
          child: IgnorePointer(
            child: Container(
              width: 50,
              color: Colors.black.withOpacity(0.0),
            ),
          ),
        )
      ]
    ]);
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
            width:
                70), //spacing to make sure the sidebar doesn't overlap over our mainscreen
        Expanded(
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2000),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) {
              return isSameDay(DateTime(2000), day);
            },
            onDaySelected: (selectedDay, focusedDay) {},
          ),
        )
      ],
    );
  }
}
