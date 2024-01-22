import 'package:flutter/material.dart';
import 'dart:async';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:chatgpt/model/question_answer.dart';
import 'package:chatgpt/theme.dart';
import 'package:chatgpt/view/components/chatgpt_answer_widget.dart';
import 'package:chatgpt/view/components/loading_widget.dart';
import 'package:chatgpt/view/components/text_input_widget.dart';
import 'package:chatgpt/view/components/user_question_widget.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: API_KEY);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

const String API_KEY = "AIzaSyDYHXDNDpE-1E5Cxc4e4MtnkWGorfkruWY";

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final gemini = Gemini.instance;
  String? answer;
  final loadingNotifier = ValueNotifier<bool>(false);
  final List<QuestionAnswer> questionAnswers = [];
  bool isLoading = false;
  late ScrollController scrollController;
  late TextEditingController inputQuestionController;
  StreamSubscription<CompletionResponse>? streamSubscription;

  @override
  void initState() {
    inputQuestionController = TextEditingController();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    inputQuestionController.dispose();
    loadingNotifier.dispose();
    scrollController.dispose();
    // streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> getChatResponse() async {
    final question = inputQuestionController.text;
    inputQuestionController.clear();
    loadingNotifier.value = true;

    setState(() => questionAnswers
        .add(QuestionAnswer(question: question, answer: StringBuffer())));
    debugPrint("here1");
    // List<Content> _messagesHistory =
    //     questionAnswers.reversed.map((questionAnswers) {
    //   if (questionAnswers.question.isNotEmpty) {
    //     return Content(
    //         parts: [Parts(text: questionAnswers.question)],
    //         role: 'user');
    //   } else {
    //     return Content(
    //         parts: [Parts(text: questionAnswers.answer.toString())],
    //         role: 'model');
    //   }
    // }).toList();

    List<Content> _messageHistory = [];

    for (var qa in questionAnswers) {
      _messageHistory
          .add(Content(parts: [Parts(text: qa.question)], role: 'user'));

      if(qa.answer.isNotEmpty)
      {
        _messageHistory.add(
          Content(parts: [Parts(text: qa.answer.toString())], role: 'model'));
          }
    }
    debugPrint(_messageHistory.toString());
    gemini
        .chat(_messageHistory)
        .then((value) => {
              if (value!.output!.isNotEmpty)
                {
                  debugPrint("here3"),
                  setState(() {
                    questionAnswers.last.answer.write(value.output);
                    _scrollToBottom();
                    isLoading = false;
                    loadingNotifier.value = false;
                  })
                }
            })
        .catchError((e) => debugPrint('chat $e'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg500Color,
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.white12,
        centerTitle: true,
        title: const Text("Gemini AI",
            style: TextStyle(fontWeight: kSemiBold, color: Color.fromARGB(255, 145, 200, 245))),
        backgroundColor: kBg300Color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildChatList(),
            TextInputWidget(
              textController: inputQuestionController,
              onSubmitted: () => getChatResponse(),
            )
          ],
        ),
      ),
    );
  }

  Expanded buildChatList() {
    return Expanded(
      child: ListView.separated(
        controller: scrollController,
        separatorBuilder: (context, index) => const SizedBox(
          height: 12,
        ),
        physics: const BouncingScrollPhysics(),
        padding:
            const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 16),
        itemCount: questionAnswers.length,
        itemBuilder: (BuildContext context, int index) {
          final question = questionAnswers[index].question;
          final answer = questionAnswers[index].answer;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              UserQuestionWidget(question: question),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: loadingNotifier,
                builder: (_, bool isLoading, __) {
                  if (answer.isEmpty && isLoading) {
                    _scrollToBottom();
                    return const LoadingWidget();
                  } else {
                    return ChatGptAnswerWidget(
                      answer: answer.toString().trim(),
                    );
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
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

