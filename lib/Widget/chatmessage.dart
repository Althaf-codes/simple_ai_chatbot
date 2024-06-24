import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {super.key,
      required this.text,
      required this.sender,
      this.isImage = false});

  final String text;
  final String sender;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8, bottom: 8, top: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: sender == "user" ? Colors.blueAccent : Colors.green,
              ),
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  sender,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
              child: isImage
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          text,
                          loadingBuilder: (context, child, loadingProgress) =>
                              loadingProgress == null
                                  ? child
                                  : const CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0, left: 8, right: 8, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          text.trim(),
                          style: TextStyle(
                              color: sender == "user"
                                  ? Colors.blue
                                  : Colors.green),
                        ),
                      ),
                    )),
        ],
      ),
    );
  }
}
