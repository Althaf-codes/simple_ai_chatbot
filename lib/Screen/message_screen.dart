import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

import '../Widget/chatmessage.dart';

class ChatgptMessageScreen extends StatefulWidget {
  const ChatgptMessageScreen({super.key});

  @override
  State<ChatgptMessageScreen> createState() => _ChatgptMessageScreenState();
}

class _ChatgptMessageScreenState extends State<ChatgptMessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  ChatGPT? chatGPT;
  bool _isImageSearch = false;

  StreamSubscription? _subscription;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance.builder(
      "your-secret-key",
    );
  }

  @override
  void dispose() {
    chatGPT!.genImgClose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");

      _subscription = chatGPT!
          .generateImageStream(request)
          .asBroadcastStream()
          .listen((response) {
        print('The image res is ${response.data!.last!.url!}');
        insertNewData(response.data!.last!.url!, isImage: true);
      });
    } else {
      final request = CompleteReq(
          prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

      _subscription = chatGPT!
          .onCompleteStream(request: request)
          .asBroadcastStream()
          .listen((response) {
        print('The response is ${response!.choices[0].text}');
        print("the msg list is ${_messages}");
        insertNewData(response.choices[0].text, isImage: false);
      });
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget messagefield() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8),
            child: Center(
              child: TextField(
                maxLines: 2,
                controller: _controller,
                onSubmitted: (value) {},
                decoration: const InputDecoration.collapsed(
                    //  border: OutlineInputBorder(
                    // borderSide:
                    //     BorderSide(color: Color.fromARGB(255, 215, 55, 244)),
                    // borderRadius: BorderRadius.all(Radius.circular(2))),
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 215, 55, 244),
                    ),
                    hintText: " Question/description"),
              ),
            ),
          ),
        ),
        VerticalDivider(
          width: 2,
          color: Colors.black,
        ),
        // TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       'Get Image',
        //       style: TextStyle(color: Color.fromARGB(255, 215, 55, 244)),
        //     )),
        IconButton(
            onPressed: () {
              _isImageSearch = true;
              _sendMessage();
            },
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Color.fromARGB(255, 215, 55, 244),
            )),
        VerticalDivider(
          indent: 5,
          endIndent: 5,
          width: 2,
          color: Colors.black,
        ),
        IconButton(
            onPressed: () {
              _isImageSearch = false;
              _sendMessage();
            },
            icon: Icon(
              Icons.send,
              color: Color.fromARGB(255, 215, 55, 244),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGpt'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            )),
            if (_isTyping)
              CircularProgressIndicator(
                color: Color.fromARGB(255, 215, 55, 244),
              ),
            const Divider(
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: messagefield()),
            ),
          ],
        ),
      ),
    );
  }
}
