import 'package:chatgpt/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatGptAnswerWidget extends StatelessWidget {
  final String answer;

  const ChatGptAnswerWidget({required this.answer, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     MarkdownStyleSheet customStyleSheet =
          MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        textScaleFactor: 1.2, // Adjust text scale as needed
        p: const TextStyle(color: Colors.white), // Default color for paragraphs
        strong: const TextStyle(color: Colors.black), // Style for bold text
        em: const TextStyle(color: Colors.white),
           ); // Style for italic text
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: SizedBox(
              height: 32,
              width: 32,
              child: Image.asset("assets/images.png")),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Markdown(
           physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          data:answer.toString().trim(),
          selectable: true,
          styleSheet: customStyleSheet,
        )
          ),
        ),
      ],
    );
  }
}
class TextColorChanger extends StatelessWidget {
  final Color textColor;
  final Widget child;

  const TextColorChanger({
    Key? key,
    required this.textColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
          color: textColor), // Set default text color for the widget subtree
      child: child,
    );
  }
}