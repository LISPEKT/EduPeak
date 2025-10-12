import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import '../theme/app_theme.dart';

class TopicPopup extends StatelessWidget {
  final dynamic topic;
  final int? currentGrade;
  final String? currentSubject;

  const TopicPopup({
    required this.topic,
    this.currentGrade,
    this.currentSubject,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      topic.imageAsset,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    topic.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Описание',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              topic.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        topic: topic,
                        currentGrade: currentGrade,
                        currentSubject: currentSubject,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Начать занятие',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}