// lib/models/exam_content_models.dart
import 'package:flutter/material.dart';

// Topic model
class Topic {
  final int id;
  final String name;
  final String? description;
  final String? imagePath;
  final int? priorityOrder;
  int progressPercentage = 0;
  
  Topic({
    required this.id,
    required this.name,
    this.description,
    this.imagePath,
    this.priorityOrder,
  });
  
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imagePath: map['image_path'],
      priorityOrder: map['priority_order'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'priority_order': priorityOrder,
    };
  }
}

// Subtopic model
class Subtopic {
  final int id;
  final int topicId;
  final String name;
  final String? description;
  final int? priorityOrder;
  
  Subtopic({
    required this.id,
    required this.topicId,
    required this.name,
    this.description,
    this.priorityOrder,
  });
  
  factory Subtopic.fromMap(Map<String, dynamic> map) {
    return Subtopic(
      id: map['id'],
      topicId: map['topic_id'],
      name: map['name'],
      description: map['description'],
      priorityOrder: map['priority_order'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'name': name,
      'description': description,
      'priority_order': priorityOrder,
    };
  }
}

// Content model
class Content {
  final int id;
  final int subtopicId;
  final String title;
  final String contentType;
  final String contentBody;
  final int? priorityOrder;
  bool isCompleted = false;
  
  Content({
    required this.id,
    required this.subtopicId,
    required this.title,
    required this.contentType,
    required this.contentBody,
    this.priorityOrder,
  });
  
  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'],
      subtopicId: map['subtopic_id'],
      title: map['title'],
      contentType: map['content_type'],
      contentBody: map['content_body'],
      priorityOrder: map['priority_order'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subtopic_id': subtopicId,
      'title': title,
      'content_type': contentType,
      'content_body': contentBody,
      'priority_order': priorityOrder,
    };
  }
}

// Practice Question model
class PracticeQuestion {
  final int id;
  final int topicId;
  final int? subtopicId;
  final String question;
  final String difficulty;
  final String? explanation;
  List<QuestionOption> options = [];
  
  PracticeQuestion({
    required this.id,
    required this.topicId,
    this.subtopicId,
    required this.question,
    required this.difficulty,
    this.explanation,
  });
  
  factory PracticeQuestion.fromMap(Map<String, dynamic> map) {
    return PracticeQuestion(
      id: map['id'],
      topicId: map['topic_id'],
      subtopicId: map['subtopic_id'],
      question: map['question'],
      difficulty: map['difficulty'],
      explanation: map['explanation'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'subtopic_id': subtopicId,
      'question': question,
      'difficulty': difficulty,
      'explanation': explanation,
    };
  }
  
  int get correctOptionIndex {
    for (int i = 0; i < options.length; i++) {
      if (options[i].isCorrect) {
        return i;
      }
    }
    return -1;
  }
}

// Question Option model
class QuestionOption {
  final int id;
  final int questionId;
  final String optionText;
  final bool isCorrect;
  
  QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });
  
  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id'],
      questionId: map['question_id'],
      optionText: map['option_text'],
      isCorrect: map['is_correct'] == 1,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect ? 1 : 0,
    };
  }
}

// Study Activity model
class StudyActivity {
  final int id;
  final int userId;
  final String activityType;
  final int? topicId;
  final int? subtopicId;
  final DateTime timestamp;
  final int? duration;
  final int? score;
  final String? topicName;
  final String? subtopicName;
  
  StudyActivity({
    required this.id,
    required this.userId,
    required this.activityType,
    this.topicId,
    this.subtopicId,
    required this.timestamp,
    this.duration,
    this.score,
    this.topicName,
    this.subtopicName,
  });
  
  factory StudyActivity.fromMap(Map<String, dynamic> map) {
    return StudyActivity(
      id: map['id'],
      userId: map['user_id'],
      activityType: map['activity_type'],
      topicId: map['topic_id'],
      subtopicId: map['subtopic_id'],
      timestamp: DateTime.parse(map['timestamp']),
      duration: map['duration'],
      score: map['score'],
      topicName: map['topic_name'],
      subtopicName: map['subtopic_name'],
    );
  }
  
  // Get appropriate icon for activity type
  IconData getActivityIcon() {
    switch (activityType) {
      case 'read_content':
        return Icons.menu_book;
      case 'watch_video':
        return Icons.video_library;
      case 'practice_quiz':
        return Icons.quiz;
      case 'take_exam':
        return Icons.assignment;
      case 'use_calculator':
        return Icons.calculate;
      default:
        return Icons.star;
    }
  }
  
  // Get appropriate color for activity type
  Color getActivityColor() {
    switch (activityType) {
      case 'read_content':
        return Colors.blue;
      case 'watch_video':
        return Colors.red;
      case 'practice_quiz':
        return Colors.orange;
      case 'take_exam':
        return Colors.purple;
      case 'use_calculator':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  // Get formatted description
  String getFormattedDescription() {
    String base = '';
    
    switch (activityType) {
      case 'read_content':
        base = 'Read study material';
        break;
      case 'watch_video':
        base = 'Watched video lecture';
        break;
      case 'practice_quiz':
        base = score != null ? 'Completed quiz - $score%' : 'Completed quiz';
        break;
      case 'take_exam':
        base = score != null ? 'Took practice exam - $score%' : 'Took practice exam';
        break;
      case 'use_calculator':
        base = 'Used calculator';
        break;
      default:
        base = 'Completed activity';
    }
    
    if (topicName != null) {
      if (subtopicName != null) {
        return '$base: $topicName - $subtopicName';
      } else {
        return '$base: $topicName';
      }
    }
    
    return base;
  }
  
  // Get friendly time format (e.g., "Today", "Yesterday", "2 days ago")
  String getFriendlyTimeFormat() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(timestamp)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}