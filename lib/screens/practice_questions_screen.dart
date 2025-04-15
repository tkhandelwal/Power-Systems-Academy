// lib/screens/practice_questions_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';

class PracticeQuestionsScreen extends StatefulWidget {
  final String? topicFilter;
  
  const PracticeQuestionsScreen({super.key, this.topicFilter});

  @override
  PracticeQuestionsScreenState createState() => PracticeQuestionsScreenState();
}

class PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  late List<PracticeQuestion> _questions;
  late List<PracticeQuestion> _filteredQuestions;
  late List<String> _topics;
  late String _selectedTopic;
  late String _selectedDifficulty;
  late List<String> _difficulties;
  
  int _currentQuestionIndex = 0;
  bool _showExplanation = false;
  bool _questionAnswered = false;
  String? _selectedAnswer;
  
  // Quiz statistics
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  List<int> _answeredQuestionIndices = [];
  bool _quizMode = false;
  int _totalQuizQuestions = 10;
  
  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    
    // Initialize topics list
    _topics = ['All Topics'];
    _topics.addAll(_getUniqueTopics());
    _selectedTopic = widget.topicFilter ?? 'All Topics';
    
    // Initialize difficulties
    _difficulties = ['All Levels', 'Basic', 'Intermediate', 'Advanced'];
    _selectedDifficulty = 'All Levels';
    
    _filterQuestions();
  }
  
  void _initializeQuestions() {
    // In a real app, these would be loaded from a database or API
    _questions = [
      PracticeQuestion(
        question: 'What is voltage regulation in a transmission line?',
        options: [
          'The change in voltage over time',
          'The percentage change in voltage from no-load to full-load conditions',
          'The control of voltage using capacitor banks',
          'The isolation of voltage spikes from the system',
        ],
        correctAnswerIndex: 1,
        explanation: 'Voltage regulation in a transmission line is defined as the percentage change in receiving-end voltage from no-load (open circuit) to full-load conditions. It is calculated as: Regulation (%) = ((Vno-load - Vfull-load) / Vfull-load) × 100%.',
        topic: 'Transmission and Distribution',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'What is the primary function of a surge arrester in a power system?',
        options: [
          'To limit inrush current during equipment startup',
          'To protect against lightning strikes and transient overvoltages',
          'To disconnect the system during overload conditions',
          'To improve power factor',
        ],
        correctAnswerIndex: 1,
        explanation: 'Surge arresters (or lightning arresters) are protective devices designed to protect electrical equipment from transient overvoltages caused by lightning strikes, switching operations, or other system disturbances by diverting surge currents to ground.',
        topic: 'Power System Protection',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'According to NEC, what is the color code typically used for a high-leg (wild leg) in a 120/240V, 3-phase, 4-wire delta system?',
        options: [
          'Green',
          'White',
          'Orange',
          'Blue',
        ],
        correctAnswerIndex: 2,
        explanation: 'According to NEC 110.15, the high-leg (also called wild leg or stinger leg) of a 120/240V, 3-phase, 4-wire delta system should be marked by an orange color or by other effective means. This leg has a higher voltage to ground (approximately 208V) compared to the other phases.',
        topic: 'Codes and Standards',
        difficulty: 'Advanced',
      ),
      PracticeQuestion(
        question: 'Which of the following is the correct expression for the power transfer in a lossless transmission line?',
        options: [
          'P = (V₁ × V₂ × sin δ) / X',
          'P = (V₁ × V₂ × cos δ) / X',
          'P = (V₁ × V₂ × sin δ) / R',
          'P = (V₁ × V₂ × cos δ) / R',
        ],
        correctAnswerIndex: 0,
        explanation: 'In a lossless transmission line, the active power transfer is expressed as P = (V₁ × V₂ × sin δ) / X, where V₁ and V₂ are the sending and receiving end voltages, X is the line reactance, and δ is the power angle (phase difference between the voltages).',
        topic: 'Power System Analysis',
        difficulty: 'Advanced',
      ),
      PracticeQuestion(
        question: 'What is the typical time-current characteristic of a fuse?',
        options: [
          'Definite time',
          'Inverse time',
          'Instantaneous',
          'Independent time',
        ],
        correctAnswerIndex: 1,
        explanation: 'Fuses typically have inverse time-current characteristics, which means they operate faster at higher fault currents and slower at lower fault currents. This characteristic allows them to coordinate with other protective devices in the system.',
        topic: 'Power System Protection',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'What is the primary purpose of a power transformer?',
        options: [
          'To convert AC power to DC power',
          'To change voltage levels in AC power systems',
          'To store electrical energy',
          'To generate electricity',
        ],
        correctAnswerIndex: 1,
        explanation: 'Power transformers are primarily used to change voltage levels in AC power systems, allowing efficient power transmission over long distances at high voltages and safe utilization at lower voltages.',
        topic: 'Transformers',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'Which of the following is NOT a common method for starting large induction motors?',
        options: [
          'Direct-on-line (DOL) starting',
          'Star-delta starting',
          'Brushless excitation',
          'Soft starter',
        ],
        correctAnswerIndex: 2,
        explanation: 'Brushless excitation is a method used for synchronous motors, not induction motors. The other options (DOL, star-delta, and soft starters) are all common methods for starting induction motors.',
        topic: 'Rotating Machines',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'In a balanced three-phase system, the relationship between line voltage (VL) and phase voltage (VP) in a wye-connected load is:',
        options: [
          'VL = VP',
          'VL = VP × √3',
          'VL = VP ÷ √3',
          'VL = VP × 3',
        ],
        correctAnswerIndex: 1,
        explanation: 'In a wye-connected (star-connected) load in a balanced three-phase system, the line voltage is √3 times the phase voltage: VL = VP × √3.',
        topic: 'Circuit Analysis',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'What is the primary function of a current transformer (CT) in power systems?',
        options: [
          'To step up voltage for transmission',
          'To measure high currents safely',
          'To store electrical energy',
          'To regulate system frequency',
        ],
        correctAnswerIndex: 1,
        explanation: 'Current transformers (CTs) are primarily used to measure high currents safely by stepping down the current to a standardized value (typically 1A or 5A) that can be safely measured by instruments.',
        topic: 'Measurement and Instrumentation',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'A 100 kVA transformer has a full-load copper loss of 1,200 W and a core loss of 800 W. Calculate its full-load efficiency at 0.8 power factor lagging.',
        options: [
          '96.8%',
          '97.5%',
          '98.0%',
          '95.2%',
        ],
        correctAnswerIndex: 0,
        explanation: 'To calculate the full-load efficiency:\n'
                     'Output power = 100 kVA × 0.8 = 80 kW\n'
                     'Input power = Output power + Core loss + Copper loss = 80 kW + 0.8 kW + 1.2 kW = 82 kW\n'
                     'Efficiency = (Output power ÷ Input power) × 100% = (80 ÷ 82) × 100% = 96.8%',
        topic: 'Transformers',
        difficulty: 'Advanced',
      ),
      PracticeQuestion(
        question: 'Which NEC article covers "Overcurrent Protection"?',
        options: [
          'Article 210',
          'Article 240',
          'Article 310',
          'Article 430',
        ],
        correctAnswerIndex: 1,
        explanation: 'NEC Article 240 covers "Overcurrent Protection" which includes requirements for fuses, circuit breakers, and other overcurrent devices. Article 210 covers "Branch Circuits," Article 310 covers "Conductors for General Wiring," and Article 430 covers "Motors, Motor Circuits, and Controllers."',
        topic: 'Codes and Standards',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'A generator delivers 10 MW at 0.8 power factor lagging. What is the reactive power delivered by the generator?',
        options: [
          '6 MVAR',
          '7.5 MVAR',
          '8 MVAR',
          '12.5 MVAR',
        ],
        correctAnswerIndex: 1,
        explanation: 'For a power triangle with active power P and power factor cos(φ):\n'
                     'Reactive power Q = P × tan(φ) = P × tan(cos⁻¹(pf))\n'
                     'Q = 10 MW × tan(cos⁻¹(0.8)) = 10 MW × tan(36.87°) = 10 MW × 0.75 = 7.5 MVAR',
        topic: 'Power System Analysis',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'What is the purpose of differential protection in transformers?',
        options: [
          'To detect voltage fluctuations',
          'To protect against overloads',
          'To detect internal faults by comparing currents',
          'To provide backup protection for external faults',
        ],
        correctAnswerIndex: 2,
        explanation: 'Differential protection in transformers works by comparing the current entering and leaving the transformer. Under normal operation or external faults, these currents should be equal (accounting for turns ratio). An internal fault causes an imbalance, triggering the relay to trip the circuit breakers and isolate the transformer.',
        topic: 'Power System Protection',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'According to NEC, what is the maximum allowed voltage drop for branch circuits?',
        options: [
          '1%',
          '3%',
          '5%',
          '8%',
        ],
        correctAnswerIndex: 1,
        explanation: 'According to NEC recommendations in the Informational Notes (not a requirement), the maximum voltage drop for branch circuits should not exceed a 3% drop. The total voltage drop for both feeders and branch circuits should not exceed 5%.',
        topic: 'Codes and Standards',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'A 3-phase, 480V, 60Hz induction motor has a nameplate rating of 100 HP and 92% efficiency at full load. What is the full load current?',
        options: [
          '92.3 A',
          '108.7 A',
          '124.8 A',
          '151.2 A',
        ],
        correctAnswerIndex: 2,
        explanation: 'For a 3-phase motor, the full load current is calculated as:\n'
                     'I = P / (√3 × V × PF × η)\n'
                     'Where P = 100 HP × 746 W/HP = 74,600 W, V = 480V, η = 0.92\n'
                     'Assuming PF = 0.85 (typical for induction motors):\n'
                     'I = 74,600 / (√3 × 480 × 0.85 × 0.92) = 74,600 / 597.8 = 124.8 A',
        topic: 'Rotating Machines',
        difficulty: 'Advanced',
      ),
      PracticeQuestion(
        question: 'What is the purpose of a grounding transformer in a power system?',
        options: [
          'To step up voltage for transmission',
          'To provide a ground reference in ungrounded systems',
          'To isolate harmonic distortion',
          'To improve power factor',
        ],
        correctAnswerIndex: 1,
        explanation: 'A grounding transformer (typically a zig-zag transformer) is used to provide a ground reference point in ungrounded or delta-connected systems. This allows ground fault detection and provides a path for zero-sequence currents during unbalanced conditions or ground faults.',
        topic: 'Transformers',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'Which IEEE standard covers "Recommended Practice for Electric Power Distribution for Industrial Plants"?',
        options: [
          'IEEE 141',
          'IEEE 242',
          'IEEE 519',
          'IEEE 1584',
        ],
        correctAnswerIndex: 0,
        explanation: 'IEEE 141, also known as the "Red Book," covers "Recommended Practice for Electric Power Distribution for Industrial Plants." IEEE 242 (Buff Book) covers protection and coordination, IEEE 519 covers harmonics, and IEEE 1584 covers arc flash hazard calculations.',
        topic: 'Codes and Standards',
        difficulty: 'Intermediate',
      ),
      PracticeQuestion(
        question: 'In power system analysis, what does the term "per unit" refer to?',
        options: [
          'The cost of electricity per unit of consumption',
          'A normalization method expressing system quantities as decimal fractions of a base value',
          'The efficiency of a power plant per unit of fuel',
          'The power output per unit area of solar panels',
        ],
        correctAnswerIndex: 1,
        explanation: 'The "per unit" system is a method of normalizing power system parameters by expressing them as decimal fractions of defined base values. This simplifies calculations, especially in transformers where turns ratios are automatically accounted for when using a common system-wide base.',
        topic: 'Power System Analysis',
        difficulty: 'Basic',
      ),
      PracticeQuestion(
        question: 'A 3-phase, 480V system supplies a balanced load of 150 kW at 0.8 power factor lagging. What is the line current?',
        options: [
          '180.4 A',
          '225.5 A',
          '312.5 A',
          '104.2 A',
        ],
        correctAnswerIndex: 0,
        explanation: 'For a 3-phase system: I = P / (√3 × V × PF)\n'
                     'I = 150,000 W / (√3 × 480 V × 0.8) = 150,000 / 831.4 = 180.4 A',
        topic: 'Circuit Analysis',
        difficulty: 'Intermediate',
      ),
    ];
  }
  
  List<String> _getUniqueTopics() {
    Set<String> uniqueTopics = {};
    for (var question in _questions) {
      uniqueTopics.add(question.topic);
    }
    return uniqueTopics.toList()..sort();
  }
  
  void _filterQuestions() {
    _filteredQuestions = _questions.where((question) {
      // Filter by topic
      bool topicMatch = _selectedTopic == 'All Topics' || question.topic == _selectedTopic;
      
      // Filter by difficulty
      bool difficultyMatch = _selectedDifficulty == 'All Levels' || question.difficulty == _selectedDifficulty;
      
      return topicMatch && difficultyMatch;
    }).toList();
    
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
      bool isCorrect = answer == _filteredQuestions[_currentQuestionIndex].options[_filteredQuestions[_currentQuestionIndex].correctAnswerIndex];
      
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
        title: Text('Practice Questions'),
        actions: [
          // Toggle between practice and quiz mode
          IconButton(
            icon: Icon(_quizMode ? Icons.book : Icons.quiz),
            onPressed: _quizMode ? _exitQuiz : _startQuiz,
            tooltip: _quizMode ? 'Exit Quiz' : 'Start Quiz',
          ),
        ],
      ),
      body: _filteredQuestions.isEmpty
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
                                items: _topics.map((topic) {
                                  return DropdownMenuItem<String>(
                                    value: topic,
                                    child: Text(topic),
                                  );
                                }).toList(),
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
                                _filteredQuestions[_currentQuestionIndex].topic,
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
                            final isSelected = _selectedAnswer == option;
                            final isCorrect = index == _filteredQuestions[_currentQuestionIndex].correctAnswerIndex;
                            
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
                                onTap: _questionAnswered ? null : () => _answerQuestion(option),
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
                                          option,
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
                                  Text(_filteredQuestions[_currentQuestionIndex].explanation),
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
                        onPressed: _questionAnswered || _quizMode ? _nextQuestion : null,
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
            ),
    );
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

class PracticeQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String topic;
  final String difficulty;
  
  PracticeQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.topic,
    required this.difficulty,
  });
}