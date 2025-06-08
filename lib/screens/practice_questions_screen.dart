// lib/screens/practice_questions_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:powersystemsacademy/services/exam_service.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';

class PracticeQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const PracticeQuestionsScreen({super.key, this.arguments});

  @override
  PracticeQuestionsScreenState createState() => PracticeQuestionsScreenState();
}

class PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  final ExamService _examService = ExamService();
  late List<PracticeQuestion> _questions;
  late List<PracticeQuestion> _filteredQuestions;
  late List<Topic> _topics;
  late String _selectedTopic;
  late String _selectedDifficulty;
  late List<String> _difficulties;
  
  int _currentQuestionIndex = 0;
  bool _showExplanation = false;
  bool _questionAnswered = false;
  String? _selectedAnswer;
  bool _isLoading = true;
  
  // Quiz statistics
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  List<int> _answeredQuestionIndices = [];
  bool _quizMode = false;
  int _totalQuizQuestions = 10;
  
  // Topic filter information
  int? _topicId;
  String? _topicFilter;
  bool _isQuiz = false;
  

  @override
  void initState() {
    super.initState();
    
    // Process any arguments passed to the screen
    if (widget.arguments != null) {
      _topicId = widget.arguments!['topicId'];
      _topicFilter = widget.arguments!['topicName'];
      _isQuiz = widget.arguments!['isQuiz'] ?? false;
    }
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize topics list
      _topics = await _examService.getTopics();
      
      // Initialize difficulties
      _difficulties = ['All Levels', 'Basic', 'Intermediate', 'Advanced'];
      
      // Set default selections
      _selectedTopic = _topicFilter ?? 'All Topics';
      _selectedDifficulty = 'All Levels';
      
      // Load all questions or topic-specific questions
      if (_topicId != null) {
        _questions = await _examService.getQuestionsForTopic(_topicId!);
      } else {
        // Load questions from all topics
        _questions = [];
        for (var topic in _topics) {
          var topicQuestions = await _examService.getQuestionsForTopic(topic.id);
          _questions.addAll(topicQuestions);
        }
      }
      
      // Apply initial filtering
      _filterQuestions();
      
      // If this is a quiz, start it automatically
      if (_isQuiz) {
        _startQuiz();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
        _questions = [];
        _filteredQuestions = [];
      });
    }
  }
  
  void _filterQuestions() {
    if (_selectedTopic == 'All Topics' && _selectedDifficulty == 'All Levels') {
      _filteredQuestions = List.from(_questions);
    } else {
      _filteredQuestions = _questions.where((question) {
        // Filter by topic
        bool topicMatch = true;
        if (_selectedTopic != 'All Topics') {
          Topic? topic = _topics.firstWhere(
            (t) => t.id == question.topicId,
            orElse: () => Topic(id: -1, name: ''),
          );
          topicMatch = topic.name == _selectedTopic;
        }
        
        // Filter by difficulty
        bool difficultyMatch = _selectedDifficulty == 'All Levels' || 
                              question.difficulty == _selectedDifficulty;
        
        return topicMatch && difficultyMatch;
      }).toList();
    }
    
    // Shuffle questions for random order
    if (_filteredQuestions.isNotEmpty) {
      _filteredQuestions.shuffle();
      _currentQuestionIndex = 0;
      _showExplanation = false;
      _questionAnswered = false;
      _selectedAnswer = null;
    }
    
    setState(() {});
  }
  
  void _answerQuestion(String answer) {
    if (_questionAnswered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _questionAnswered = true;
      
      // Record result
      bool isCorrect = answer == _filteredQuestions[_currentQuestionIndex].options[
        _filteredQuestions[_currentQuestionIndex].correctOptionIndex
      ].optionText;
      
      if (isCorrect) {
        _correctAnswers++;
      } else {
        _incorrectAnswers++;
      }
      
      if (_quizMode) {
        _answeredQuestionIndices.add(_currentQuestionIndex);
      }
    });
  }
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _filteredQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false;
        _questionAnswered = false;
        _selectedAnswer = null;
      });
    } else if (_quizMode && _answeredQuestionIndices.length < _totalQuizQuestions) {
      // Find an unanswered question for the quiz
      List<int> remainingIndices = List.generate(_filteredQuestions.length, (i) => i)
          .where((i) => !_answeredQuestionIndices.contains(i))
          .toList();
      
      if (remainingIndices.isNotEmpty) {
        setState(() {
          _currentQuestionIndex = remainingIndices[0];
          _showExplanation = false;
          _questionAnswered = false;
          _selectedAnswer = null;
        });
      } else {
        // No more questions available
        _showQuizResults();
      }
    } else if (_quizMode) {
      // End of quiz
      _showQuizResults();
    }
  }
  
  void _prevQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showExplanation = false;
        _questionAnswered = false;
        _selectedAnswer = null;
      });
    }
  }
  
  void _toggleExplanation() {
    setState(() {
      _showExplanation = !_showExplanation;
    });
  }
  
  void _startQuiz() {
    // Ensure we have enough questions
    if (_filteredQuestions.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough questions available. Please adjust filters.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _quizMode = true;
      _correctAnswers = 0;
      _incorrectAnswers = 0;
      _answeredQuestionIndices = [];
      _currentQuestionIndex = 0;
      _showExplanation = false;
      _questionAnswered = false;
      _selectedAnswer = null;
      
      // Limit total questions for quiz to available questions or 10, whichever is smaller
      _totalQuizQuestions = min(_filteredQuestions.length, 10);
      
      // Shuffle questions for variety
      _filteredQuestions.shuffle();
    });
  }
  
  void _exitQuiz() {
    setState(() {
      _quizMode = false;
      _filterQuestions(); // Reset to regular mode
    });
  }
  
  void _showQuizResults() {
    // Log quiz completion in the database
    Topic? topic = _topics.firstWhere(
      (t) => t.name == _selectedTopic,
      orElse: () => Topic(id: -1, name: ''),
    );
    
    if (topic.id != -1) {
      int score = ((_correctAnswers / _totalQuizQuestions) * 100).round();
      _examService.logQuizCompletion(topic.id, null, score);
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You answered $_correctAnswers out of $_totalQuizQuestions questions correctly.',
              style: TextStyle(fontSize: 16),
            ),
            if (_incorrectAnswers > 0)
              Text(
                'Incorrect answers: $_incorrectAnswers',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            SizedBox(height: 16),
            Text(
              'Score: ${((_correctAnswers / _totalQuizQuestions) * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _correctAnswers >= (_totalQuizQuestions / 2) ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text('Would you like to:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitQuiz();
            },
            child: Text('Exit Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz(); // Start a new quiz
            },
            child: Text('Try Another Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_topicFilter != null ? '$_topicFilter Questions' : 'Practice Questions'),
        actions: [
          // Toggle between practice and quiz mode
          IconButton(
            icon: Icon(_quizMode ? Icons.book : Icons.quiz),
            onPressed: _quizMode ? _exitQuiz : _startQuiz,
            tooltip: _quizMode ? 'Exit Quiz' : 'Start Quiz',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_filteredQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No questions match your filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try adjusting your topic or difficulty filters',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTopic = 'All Topics';
                            _selectedDifficulty = 'All Levels';
                            _filterQuestions();
                          });
                        },
                        child: Text('Reset Filters'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (!_quizMode) ...[
                      // Filter controls (not shown in quiz mode)
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedTopic,
                                    decoration: InputDecoration(
                                      labelText: 'Topic',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'All Topics',
                                        child: Text('All Topics'),
                                      ),
                                      ..._topics.map((topic) {
                                        return DropdownMenuItem<String>(
                                          value: topic.name,
                                          child: Text(topic.name),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTopic = value!;
                                        _filterQuestions();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDifficulty,
                                    decoration: InputDecoration(
                                      labelText: 'Difficulty',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    items: _difficulties.map((difficulty) {
                                      return DropdownMenuItem<String>(
                                        value: difficulty,
                                        child: Text(difficulty),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDifficulty = value!;
                                        _filterQuestions();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Showing ${_filteredQuestions.length} questions',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Quiz progress indicator
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quiz Progress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_answeredQuestionIndices.length} of $_totalQuizQuestions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _answeredQuestionIndices.length / _totalQuizQuestions,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Question content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Topic and difficulty badges
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _getTopicName(_filteredQuestions[_currentQuestionIndex].topicId),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(_filteredQuestions[_currentQuestionIndex].difficulty).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _filteredQuestions[_currentQuestionIndex].difficulty,
                                    style: TextStyle(
                                      color: _getDifficultyColor(_filteredQuestions[_currentQuestionIndex].difficulty),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Question text
                            Text(
                              'Question ${_currentQuestionIndex + 1}${_quizMode ? ' of $_totalQuizQuestions' : ' of ${_filteredQuestions.length}'}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _filteredQuestions[_currentQuestionIndex].question,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24),
                            
                            // Options
                            ...List.generate(
                              _filteredQuestions[_currentQuestionIndex].options.length,
                              (index) {
                                final option = _filteredQuestions[_currentQuestionIndex].options[index];
                                final isSelected = _selectedAnswer == option.optionText;
                                final isCorrect = option.isCorrect;
                                
                                // Determine option color based on state
                                Color cardColor;
                                if (_questionAnswered) {
                                  if (isCorrect) {
                                    cardColor = Colors.green.shade50;
                                  } else if (isSelected && !isCorrect) {
                                    cardColor = Colors.red.shade50;
                                  } else {
                                    cardColor = Colors.grey.shade50;
                                  }
                                } else {
                                  cardColor = isSelected ? Colors.blue.shade50 : Colors.grey.shade50;
                                }
                                
                                return Card(
                                  color: cardColor,
                                  elevation: isSelected ? 2 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: _questionAnswered
                                          ? (isCorrect
                                              ? Colors.green
                                              : (isSelected ? Colors.red : Colors.grey.shade300))
                                          : (isSelected ? Colors.blue : Colors.grey.shade300),
                                      width: isSelected || (isCorrect && _questionAnswered) ? 2 : 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: _questionAnswered ? null : () => _answerQuestion(option.optionText),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _questionAnswered
                                                  ? (isCorrect
                                                      ? Colors.green
                                                      : (isSelected ? Colors.red : Colors.grey.shade300))
                                                  : (isSelected ? Colors.blue : Colors.grey.shade300),
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(65 + index), // A, B, C, D
                                                style: TextStyle(
                                                  color: _questionAnswered
                                                      ? (isCorrect || isSelected ? Colors.white : Colors.black)
                                                      : (isSelected ? Colors.white : Colors.black),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              option.optionText,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (_questionAnswered) ...[
                                            SizedBox(width: 8),
                                            Icon(
                                              isCorrect ? Icons.check_circle : (isSelected ? Icons.cancel : null),
                                              color: isCorrect ? Colors.green : Colors.red,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Explanation section
                            if (_questionAnswered) ...[
                              OutlinedButton.icon(
                                onPressed: _toggleExplanation,
                                icon: Icon(
                                  _showExplanation ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.blue,
                                ),
                                label: Text(_showExplanation ? 'Hide Explanation' : 'Show Explanation'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              if (_showExplanation) ...[
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Explanation:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(_filteredQuestions[_currentQuestionIndex].explanation ?? 'No explanation available.'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Navigation controls
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _currentQuestionIndex > 0 ? _prevQuestion : null,
                            icon: Icon(Icons.arrow_back),
                            label: Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          if (!_quizMode && !_questionAnswered)
                            OutlinedButton.icon(
                              onPressed: () => _toggleExplanation(),
                              icon: Icon(Icons.help_outline),
                              label: Text('Hint'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ElevatedButton.icon(
                            onPressed: _questionAnswered ? _nextQuestion : null,
                            icon: Icon(Icons.arrow_forward),
                            label: Text('Next'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
          ),
    );
  }
  
  // Helper method to get topic name from topic ID
  String _getTopicName(int topicId) {
    for (var topic in _topics) {
      if (topic.id == topicId) {
        return topic.name;
      }
    }
    return 'Unknown Topic';
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Basic':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}