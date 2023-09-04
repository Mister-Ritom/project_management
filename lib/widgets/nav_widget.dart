import 'package:flutter/material.dart';

import '../models/nav_btn.dart';

class NavWidget extends StatefulWidget {
  final NavBtn btn;
  final VoidCallback onTap;

  const NavWidget({super.key, required this.btn, required this.onTap,});

  @override
  State<StatefulWidget> createState() => _NavWidgetState();

}
class _NavWidgetState extends State<NavWidget> {
  bool showTitle = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovered) {
        setState(() {
          showTitle = isHovered;
        });
      },
      child: Container(
        height: 60.0,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              widget.btn.icon,
              size: 20.0,
              color: showTitle ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            ),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showTitle ? 1.0 : 0.0,
                child: Text(
                  widget.btn.title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}