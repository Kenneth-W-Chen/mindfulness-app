// mellowmazeEngine.dart
import 'package:flutter/material.dart';

/// Represents a single choice in a question.
class Choice {
  final String text;
  /// Optional pointer to the next question index (for branching).
  final int? next;
  Choice({required this.text, this.next});
}

/// Represents one question in the adventure.
class MazeQuestion {
  final String text;
  final List<Choice> choices;
  /// Index of the “correct” answer (used for feedback/health update).
  final int correctIndex;
  MazeQuestion({
    required this.text,
    required this.choices,
    required this.correctIndex,
  });
}

/// Represents a full level in Mellow Maze:
/// - A theme introduction (blurb and key pointers)
/// - A series of adventure questions
/// - A reflection message at the end.
class MellowMazeLevel {
  final String themeBlurb;
  final List<String> keyPointers;
  final List<MazeQuestion> questions;
  final String reflection;
  MellowMazeLevel({
    required this.themeBlurb,
    required this.keyPointers,
    required this.questions,
    required this.reflection,
  });
}

/// Example levels list with a revised narrative inspired by the chariot simile.
final List<MellowMazeLevel> levels = [
  MellowMazeLevel(
    themeBlurb: "Who Are You? – Explore the Nature of Self",
    keyPointers: [
      "Examine your inner experience.",
      "Question the idea of a fixed identity.",
      "Recognize the interplay of many parts.",
      "Embrace impermanence."
    ],
    questions: [
      MazeQuestion(
        text: "Who are you? Before you answer, reflect: can you identify a single, unchanging self?",
        choices: [
          Choice(text: "I am a fixed, singular entity.", next: 1),
          Choice(text: "I am a composite of many parts.", next: 1),
          Choice(text: "I am uncertain about who I am.", next: 1),
        ],
        // We want the user to lean toward the idea of a composite self.
        correctIndex: 1,
      ),
      MazeQuestion(
        text: "Consider a chariot – it consists of a pole, axle, wheels, and other parts. Is any one part, by itself, the chariot?",
        choices: [
          Choice(text: "Yes, one part defines the chariot.", next: 2),
          Choice(text: "No, no single part is the chariot.", next: 2),
          Choice(text: "Maybe, if that part is the most important.", next: 2),
        ],
        correctIndex: 1,
      ),
      MazeQuestion(
        text: "Now, if you gather all these parts together, is there something extra that makes it a chariot?",
        choices: [
          Choice(text: "Yes, there is an essence beyond the parts.", next: 3),
          Choice(text: "No, the chariot is merely the sum of its parts.", next: 3),
          Choice(text: "It might be both more and less than its parts.", next: 3),
        ],
        correctIndex: 1,
      ),
      MazeQuestion(
        text: "Reflect on yourself: are you a fixed 'self' or a collection of experiences and parts that change over time?",
        choices: [
          Choice(text: "I have an unchanging core.", next: 4),
          Choice(text: "I am a mosaic of transient parts.", next: 4),
          Choice(text: "I am unsure how to describe myself.", next: 4),
        ],
        correctIndex: 1,
      ),
      MazeQuestion(
        text: "Finally, what insight resonates with you regarding the nature of ‘I’?",
        choices: [
          Choice(text: "The self is an illusion; we are ever-changing.", next: null),
          Choice(text: "There is a permanent, unchanging self.", next: null),
          Choice(text: "Truth lies somewhere in between.", next: null),
        ],
        correctIndex: 0,
      ),
    ],
    reflection: "Reflection: Just as the chariot is nothing more than the sum of its parts, your sense of self is a fluid tapestry of experiences. Recognizing that no singular, fixed 'I' exists can free you to embrace change and discover a deeper, ever-evolving awareness.",
  ),
];
