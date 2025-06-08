// lib/database/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Database initialization
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pe_power_prep.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Topics table
    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        priority_order INTEGER
      )
    ''');
    
    // Subtopics table
    await db.execute('''
      CREATE TABLE subtopics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        priority_order INTEGER,
        FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE CASCADE
      )
    ''');
    
    // Content table (for text content, formulas, etc.)
    await db.execute('''
      CREATE TABLE content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtopic_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content_type TEXT NOT NULL,
        content_body TEXT NOT NULL,
        priority_order INTEGER,
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id) ON DELETE CASCADE
      )
    ''');
    
    // Practice Questions table
    await db.execute('''
      CREATE TABLE practice_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id INTEGER NOT NULL,
        subtopic_id INTEGER,
        question TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        explanation TEXT,
        FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE CASCADE,
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id) ON DELETE SET NULL
      )
    ''');
    
    // Question Options table
    await db.execute('''
      CREATE TABLE question_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        option_text TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        FOREIGN KEY (question_id) REFERENCES practice_questions (id) ON DELETE CASCADE
      )
    ''');
    
    // User Progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1,
        content_id INTEGER NOT NULL,
        content_type TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completion_date TEXT,
        UNIQUE(user_id, content_id, content_type)
      )
    ''');
    
    // User Exam Plan table
    await db.execute('''
      CREATE TABLE user_exam_plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1,
        exam_date TEXT,
        weekly_study_hours INTEGER,
        UNIQUE(user_id)
      )
    ''');
    
    // Study History table
    await db.execute('''
      CREATE TABLE study_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1,
        activity_type TEXT NOT NULL,
        topic_id INTEGER,
        subtopic_id INTEGER,
        timestamp TEXT NOT NULL,
        duration INTEGER,
        score INTEGER,
        FOREIGN KEY (topic_id) REFERENCES topics (id) ON DELETE SET NULL,
        FOREIGN KEY (subtopic_id) REFERENCES subtopics (id) ON DELETE SET NULL
      )
    ''');
    
    // Load initial data
    await _seedInitialData(db);
  }
  
  // Database upgrade logic
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
  }
  
  // Seed initial data (topics, subtopics, etc.)
  Future<void> _seedInitialData(Database db) async {
    // Insert topics
    List<Map<String, dynamic>> topics = [
      {
        'name': 'Power System Analysis',
        'description': 'Understanding power flow, fault analysis, and stability studies',
        'image_path': 'assets/images/power_system_analysis.png',
        'priority_order': 1
      },
      {
        'name': 'Electrical Equipment',
        'description': 'Transformers, motors, generators, and protective devices',
        'image_path': 'assets/images/electrical_equipment.png',
        'priority_order': 2
      },
      {
        'name': 'Power Transmission',
        'description': 'Transmission line parameters, HVDC, and networks',
        'image_path': 'assets/images/power_transmission.png',
        'priority_order': 3
      },
      {
        'name': 'Power Distribution',
        'description': 'Distribution systems design and analysis',
        'image_path': 'assets/images/power_distribution.png',
        'priority_order': 4
      },
      {
        'name': 'Codes & Standards',
        'description': 'NEC, IEEE standards, and regulatory requirements',
        'image_path': 'assets/images/codes_standards.png',
        'priority_order': 5
      },
    ];
    
    for (var topic in topics) {
      await db.insert('topics', topic);
    }
    
    // Insert sample subtopics for Power System Analysis
    List<Map<String, dynamic>> subtopics = [
      {
        'topic_id': 1,
        'name': 'Load Flow Studies',
        'description': 'Analysis of power flow in electrical networks',
        'priority_order': 1
      },
      {
        'topic_id': 1,
        'name': 'Fault Analysis',
        'description': 'Calculating fault currents and system response to faults',
        'priority_order': 2
      },
      {
        'topic_id': 1,
        'name': 'Power System Stability',
        'description': 'Transient and steady-state stability analysis',
        'priority_order': 3
      }
    ];
    
    for (var subtopic in subtopics) {
      await db.insert('subtopics', subtopic);
    }
    
    // Insert sample content
    List<Map<String, dynamic>> contents = [
      {
        'subtopic_id': 1,
        'title': 'Introduction to Load Flow Analysis',
        'content_type': 'text',
        'content_body': 'Load flow studies are used to determine the steady-state operation of an electric power system. They analyze the power system in normal steady-state operation.',
        'priority_order': 1
      },
      {
        'subtopic_id': 1,
        'title': 'Load Flow Methods',
        'content_type': 'text',
        'content_body': 'Common load flow methods include the Gauss-Seidel, Newton-Raphson, and Fast Decoupled methods. Each has advantages in different scenarios.',
        'priority_order': 2
      }
    ];
    
    for (var content in contents) {
      await db.insert('content', content);
    }
    
    // Insert sample practice questions
    int questionId = await db.insert('practice_questions', {
      'topic_id': 1,
      'subtopic_id': 1,
      'question': 'What is the primary purpose of a load flow study?',
      'difficulty': 'Basic',
      'explanation': 'Load flow studies are primarily used to determine the steady-state operation of an electric power system. They help engineers analyze voltage profiles, power flows, and losses under normal operating conditions.'
    });
    
    // Insert options for the question
    List<Map<String, dynamic>> options = [
      {
        'question_id': questionId,
        'option_text': 'To determine fault currents',
        'is_correct': 0
      },
      {
        'question_id': questionId,
        'option_text': 'To analyze steady-state power system operation',
        'is_correct': 1
      },
      {
        'question_id': questionId,
        'option_text': 'To design lightning protection',
        'is_correct': 0
      },
      {
        'question_id': questionId,
        'option_text': 'To calculate transient stability',
        'is_correct': 0
      }
    ];
    
    for (var option in options) {
      await db.insert('question_options', option);
    }
  }
  
  // Topic-related methods
  Future<List<Topic>> getTopics() async {
    Database db = await database;
    var results = await db.query('topics', orderBy: 'priority_order ASC');
    return results.map((map) => Topic.fromMap(map)).toList();
  }
  
  Future<Topic> getTopic(int id) async {
    Database db = await database;
    var results = await db.query('topics', where: 'id = ?', whereArgs: [id]);
    return Topic.fromMap(results.first);
  }
  
  // Subtopic-related methods
  Future<List<Subtopic>> getSubtopicsForTopic(int topicId) async {
    Database db = await database;
    var results = await db.query(
      'subtopics',
      where: 'topic_id = ?',
      whereArgs: [topicId],
      orderBy: 'priority_order ASC'
    );
    return results.map((map) => Subtopic.fromMap(map)).toList();
  }
  
  // Content-related methods
  Future<List<Content>> getContentForSubtopic(int subtopicId) async {
    Database db = await database;
    var results = await db.query(
      'content',
      where: 'subtopic_id = ?',
      whereArgs: [subtopicId],
      orderBy: 'priority_order ASC'
    );
    return results.map((map) => Content.fromMap(map)).toList();
  }
  
  // Practice question methods
  Future<List<PracticeQuestion>> getQuestionsForTopic(int topicId, {String? difficulty}) async {
    Database db = await database;
    String whereClause = 'topic_id = ?';
    List<Object> whereArgs = [topicId];
    
    if (difficulty != null && difficulty != 'All Levels') {
      whereClause += ' AND difficulty = ?';
      whereArgs.add(difficulty);
    }
    
    var results = await db.query(
      'practice_questions',
      where: whereClause,
      whereArgs: whereArgs
    );
    
    List<PracticeQuestion> questions = [];
    for (var map in results) {
      PracticeQuestion question = PracticeQuestion.fromMap(map);
      
      // Get options for each question
      var optionResults = await db.query(
        'question_options',
        where: 'question_id = ?',
        whereArgs: [question.id]
      );
      
      question.options = optionResults.map((optMap) => QuestionOption.fromMap(optMap)).toList();
      questions.add(question);
    }
    
    return questions;
  }
  
  // User progress methods
  Future<void> updateProgress(int contentId, String contentType, bool isCompleted) async {
    Database db = await database;
    String completionDate = isCompleted ? DateTime.now().toIso8601String() : '';
    
    await db.insert(
      'user_progress',
      {
        'user_id': 1,
        'content_id': contentId,
        'content_type': contentType,
        'is_completed': isCompleted ? 1 : 0,
        'completion_date': completionDate
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
  
  Future<Map<String, dynamic>> getTopicProgress(int topicId) async {
    Database db = await database;
    
    // Get content IDs for the topic
    var subtopicResults = await db.query(
      'subtopics',
      columns: ['id'],
      where: 'topic_id = ?',
      whereArgs: [topicId]
    );
    
    List<int> subtopicIds = subtopicResults.map((m) => m['id'] as int).toList();
    
    if (subtopicIds.isEmpty) {
      return {'completed': 0, 'total': 0, 'percentage': 0};
    }
    
    String subtopicIdList = subtopicIds.join(',');
    
    // Count all content items
    var totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM content WHERE subtopic_id IN ($subtopicIdList)'
    );
    int total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    // Count completed content items
    var completedResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM user_progress 
      WHERE content_type = 'content' 
      AND is_completed = 1 
      AND content_id IN (
        SELECT id FROM content WHERE subtopic_id IN ($subtopicIdList)
      )
    ''');
    int completed = Sqflite.firstIntValue(completedResult) ?? 0;
    
    int percentage = total > 0 ? ((completed / total) * 100).round() : 0;
    
    return {
      'completed': completed,
      'total': total,
      'percentage': percentage
    };
  }
  
  // Study history methods
  Future<int> logStudyActivity({
    required String activityType,
    int? topicId,
    int? subtopicId,
    int? duration,
    int? score
  }) async {
    Database db = await database;
    
    return await db.insert(
      'study_history',
      {
        'user_id': 1,
        'activity_type': activityType,
        'topic_id': topicId,
        'subtopic_id': subtopicId,
        'timestamp': DateTime.now().toIso8601String(),
        'duration': duration,
        'score': score
      }
    );
  }
  
  Future<List<StudyActivity>> getRecentStudyActivities(int limit) async {
    Database db = await database;
    
    var results = await db.rawQuery('''
      SELECT sh.*, t.name as topic_name, s.name as subtopic_name 
      FROM study_history sh
      LEFT JOIN topics t ON sh.topic_id = t.id
      LEFT JOIN subtopics s ON sh.subtopic_id = s.id
      ORDER BY sh.timestamp DESC
      LIMIT ?
    ''', [limit]);
    
    return results.map((map) => StudyActivity.fromMap(map)).toList();
  }
  
  // Exam plan methods
  Future<void> saveExamPlan(DateTime examDate, int weeklyStudyHours) async {
    Database db = await database;
    
    await db.insert(
      'user_exam_plan',
      {
        'user_id': 1,
        'exam_date': examDate.toIso8601String(),
        'weekly_study_hours': weeklyStudyHours
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
  
  Future<Map<String, dynamic>?> getExamPlan() async {
    Database db = await database;
    
    var results = await db.query(
      'user_exam_plan',
      where: 'user_id = ?',
      whereArgs: [1]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return results.first;
  }
}