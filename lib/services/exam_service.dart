// lib/services/exam_service.dart
import 'package:powersystemsacademy/database/database_helper.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';
import 'package:powersystemsacademy/models/recent_activity.dart';

/// Service to manage exam content data and user progress
class ExamService {
  // Singleton pattern
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;
  ExamService._internal();
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Topic methods
  Future<List<Topic>> getTopics() async {
    List<Topic> topics = await _dbHelper.getTopics();
    
    // Load progress for each topic
    for (var topic in topics) {
      Map<String, dynamic> progress = await _dbHelper.getTopicProgress(topic.id);
      topic.progressPercentage = progress['percentage'];
    }
    
    return topics;
  }
  
  Future<Topic> getTopic(int id) async {
    Topic topic = await _dbHelper.getTopic(id);
    Map<String, dynamic> progress = await _dbHelper.getTopicProgress(topic.id);
    topic.progressPercentage = progress['percentage'];
    return topic;
  }
  
  // Subtopic methods
  Future<List<Subtopic>> getSubtopicsForTopic(int topicId) async {
    return await _dbHelper.getSubtopicsForTopic(topicId);
  }
  
  // Content methods
  Future<List<Content>> getContentForSubtopic(int subtopicId) async {
    return await _dbHelper.getContentForSubtopic(subtopicId);
  }
  
  // Mark content as completed
  Future<void> markContentAsCompleted(int contentId, bool isCompleted) async {
    await _dbHelper.updateProgress(contentId, 'content', isCompleted);
    
    // Log study activity if completed
    if (isCompleted) {
      await _dbHelper.logStudyActivity(
        activityType: 'read_content',
        // Note: We're not tracking topic/subtopic here since we only have contentId
        // In a real app, you might want to query for this information
      );
    }
  }
  
  // Practice question methods
  Future<List<PracticeQuestion>> getQuestionsForTopic(int topicId, {String? difficulty}) async {
    return await _dbHelper.getQuestionsForTopic(topicId, difficulty: difficulty);
  }
  
  // Log quiz completion
  Future<void> logQuizCompletion(int topicId, int? subtopicId, int score) async {
    await _dbHelper.logStudyActivity(
      activityType: 'practice_quiz',
      topicId: topicId,
      subtopicId: subtopicId,
      score: score
    );
  }
  
  // Log exam completion
  Future<void> logExamCompletion(int score) async {
    await _dbHelper.logStudyActivity(
      activityType: 'take_exam',
      score: score
    );
  }
  
  // Exam plan methods
  Future<void> saveExamPlan(DateTime examDate, int weeklyStudyHours) async {
    await _dbHelper.saveExamPlan(examDate, weeklyStudyHours);
  }
  
  Future<Map<String, dynamic>?> getExamPlan() async {
    return await _dbHelper.getExamPlan();
  }
  
  // Study history methods
  Future<List<StudyActivity>> getRecentActivities(int limit) async {
    return await _dbHelper.getRecentStudyActivities(limit);
  }
  
  // Convert study activities to Recent Activity model for UI
  List<RecentActivity> convertToRecentActivities(List<StudyActivity> activities) {
    return activities.map((activity) {
      return RecentActivity(
        title: activity.activityType.split('_').map((word) => 
          word.substring(0, 1).toUpperCase() + word.substring(1)).join(' '),
        description: activity.getFormattedDescription(),
        time: activity.getFriendlyTimeFormat(),
        iconData: activity.getActivityIcon(),
        iconColor: activity.getActivityColor(),
      );
    }).toList();
  }
}