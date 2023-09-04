import 'package:flutter/material.dart';

class SettingNav extends StatefulWidget {
  const SettingNav({Key? key}) : super(key: key);

  @override
  State<SettingNav> createState() => _SettingNavState();
}
class _SettingNavState extends State<SettingNav> {
    @override
    Widget build(BuildContext context) {
      return const Center(
        child: Text("Setting Page"),
      );
    }
}