import 'package:flutter/material.dart';

class SideNavOptions extends StatelessWidget {
  const SideNavOptions({
    Key? key,
    required this.onPressedTranslate,
    required this.onPressedSpeak,
    required this.onClear,
  }) : super(key: key);
  final Function()? onPressedTranslate;
  final Function()? onPressedSpeak;
  final Function()? onClear;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          tooltip: "Clear all",
          backgroundColor: onClear == null ? Colors.grey : Colors.orange,
          onPressed: onClear,
          child: const Center(
            child: Icon(
              Icons.clear_all,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          tooltip: "Speak",
          backgroundColor: onPressedSpeak == null ? Colors.grey : Colors.red,
          onPressed: onPressedSpeak,
          child: const Center(
            child: Icon(
              Icons.campaign_outlined,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          tooltip: "Translate",
          backgroundColor:
              onPressedTranslate == null ? Colors.grey : Colors.blue,
          onPressed: onPressedTranslate,
          child: const Center(
            child: Icon(
              Icons.translate_rounded,
              color: Colors.white,
            ),
          ),
        ),
        // FloatingActionButton(
        //   onPressed: () {},
        // ),
        // Container(
        //   width: 60,
        //   height: 60,
        //   decoration: BoxDecoration(
        //     color: Colors.blue,
        //     shape: BoxShape.circle,
        //   ),
        // )
      ],
    );
  }
}
