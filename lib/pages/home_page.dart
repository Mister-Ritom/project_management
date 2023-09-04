import 'package:flutter/material.dart';
import 'package:project_management/nav_pages/home_nav.dart';
import 'package:project_management/nav_pages/message_nav.dart';
import 'package:project_management/nav_pages/setting_nav.dart';
import 'package:project_management/widgets/nav_widget.dart';

import '../models/nav_btn.dart';
import '../widgets/project_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  Widget _body = const HomeNav();
  List<NavBtn> navButtons = [
    NavBtn(title: "Home", icon: Icons.home_outlined, widget: const HomeNav()),
    NavBtn(title: "Message", icon: Icons.chat_bubble_outline_outlined, widget: const MessageNav()),
    NavBtn(title: "Settings", icon: Icons.settings_outlined, widget: const SettingNav()),
  ];

  Widget _getBody(bool isDesktop) {
    if (isDesktop) {
      return Stack(
        children: [
          _body,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedContainer(
              //some decorations
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12.0,
                      spreadRadius: 3.0,
                    ),
                  ],
                  //rounded borders
                  borderRadius: BorderRadius.circular(12.0),
                ),
                duration: const Duration(milliseconds: 300), // Animation duration
                curve: Curves.easeInOut,
                width: 75,
                height: 180,
                child: ListView.builder(
                    itemCount: navButtons.length,
                    itemBuilder: (context, index) =>
                        NavWidget(btn: navButtons[index], onTap: ()
                        {
                          setState(() {
                            _body = navButtons[index].widget;
                          });
                        },
                        )
                )
            ),
          ),
        ],
      );
    }
    else {
      return _body;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 720;
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        items: navButtons.map((e) => BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.title,
        )).toList(),
        onTap: (index) {
          setState(() {
            _body = navButtons[index].widget;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProjectDialog,
        tooltip: "Add project",
        //rounded shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        //change hover color
        hoverColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: _getBody(isDesktop)
    );
  }

  void _openAddProjectDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const CreateProjectDialog();
      },
    );
  }

}