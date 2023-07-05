import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, this.imagebytes});
  final String message;
  final Uint8List? imagebytes;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.imagebytes == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 250,
          child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: const Color(0xffdcf8c6),
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: ExpandableText(
                        widget.message,
                        expandText: 'show more',
                        collapseText: 'show less',
                        maxLines: 21,
                        linkColor: Colors.blue,
                      ))
                ],
              )),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 250,
          //height: 250,
          child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: const Color(0xffdcf8c6),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            widget.imagebytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        ExpandableText(
                          widget.message,
                          expandText: 'show more',
                          collapseText: 'show less',
                          maxLines: 21,
                          linkColor: Colors.blue,
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
      );
    }
  }
}
