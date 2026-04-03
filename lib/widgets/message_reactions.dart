// lib/widgets/message_reactions.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageReactions extends StatelessWidget {
  final List<MessageReaction> reactions;
  final Function(String) onReact;

  const MessageReactions({
    Key? key,
    required this.reactions,
    required this.onReact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactions.map((reaction) {
          return GestureDetector(
            onTap: () => onReact(reaction.reaction),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: reaction.userReacted
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: reaction.userReacted
                    ? Border.all(color: Colors.blue, width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(reaction.reaction, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 2),
                  Text(
                    '${reaction.count}',
                    style: TextStyle(
                      fontSize: 10,
                      color: reaction.userReacted ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}