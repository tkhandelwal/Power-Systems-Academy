// lib/screens/nec_reference_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NECReferenceScreen extends StatefulWidget {
  const NECReferenceScreen({super.key});

  @override
  NECReferenceScreenState createState() => NECReferenceScreenState();
}

class NECReferenceScreenState extends State<NECReferenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showKeyArticles = true;
  final List<NECArticle> _allArticles = [];
  List<NECArticle> _filteredArticles = [];
  List<NECArticle> _bookmarkedArticles = [];
  int _selectedChapterIndex = -1; // -1 means "All Chapters"
  List<String> _chapterTitles = [];
  bool _isSearching = false;
  
  // Tabs
  int _currentTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeNECData();
    _filteredArticles = _getKeyArticles();
  }
  
  void _initializeNECData() {
    // In a real app, this would be loaded from a database or API
    // This is a simplified representation of NEC for demo purposes
    
    // Create chapters
    _chapterTitles = [
      'All Chapters',
      '1: General',
      '2: Wiring and Protection',
      '3: Wiring Methods and Materials',
      '4: Equipment for General Use',
      '5: Special Occupancies',
      '6: Special Equipment',
      '7: Special Conditions',
      '8: Communications Systems',
      '9: Tables',
    ];
    
    // Create articles for different chapters
    _allArticles.addAll([
      // Chapter 1: General
      NECArticle(
        number: '100',
        title: 'Definitions',
        chapter: 1,
        summary: 'Contains definitions of terms used throughout the code.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '100.1 Scope',
            text: 'This article contains definitions essential to the proper application of this Code. It does not include commonly defined general terms or commonly defined technical terms from related codes and standards.',
          ),
          NECContentSection(
            title: '100.2 Definitions',
            text: 'The definitions in this section apply to the entire code and include terms like Accessible, Ampacity, Branch Circuit, Circuit Breaker, Conductor, etc.',
          ),
        ],
        peExamNotes: 'Critical for understanding terminology used in NEC. Knowing definitions is essential for the PE exam as they set the foundation for code interpretation.',
      ),
      NECArticle(
        number: '110',
        title: 'Requirements for Electrical Installations',
        chapter: 1,
        summary: 'General requirements for electrical installations including approvals, markings, conductors, and connections.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '110.1 Scope',
            text: 'This article covers general requirements for the examination and approval, installation and use, access to and spaces about electrical conductors and equipment.',
          ),
          NECContentSection(
            title: '110.3 Examination, Identification, Installation, Use, and Listing',
            text: 'Requires that electrical equipment be listed for the purpose when available, suitable for installation according to the code, and installed according to any instructions included in the listing or labeling.',
          ),
          NECContentSection(
            title: '110.12 Mechanical Execution of Work',
            text: 'Electrical equipment shall be installed in a neat and workmanlike manner.',
          ),
          NECContentSection(
            title: '110.14 Electrical Connections',
            text: 'Covers requirements for electrical connections, including provisions for aluminum conductors and temperature limitations.',
          ),
        ],
        peExamNotes: 'Pay special attention to 110.14 for temperature ratings of conductors and terminal ratings. A frequent exam topic is determining the ampacity of conductors based on termination temperature limitations.',
      ),
      
      // Chapter 2: Wiring and Protection
      NECArticle(
        number: '210',
        title: 'Branch Circuits',
        chapter: 2,
        summary: 'Requirements for branch circuits including classifications, required outlets, and loads.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '210.1 Scope',
            text: 'This article covers branch circuits except for branch circuits that supply only motor loads, which are covered in Article 430.',
          ),
          NECContentSection(
            title: '210.3 Rating',
            text: 'Branch circuits shall be rated in accordance with the maximum permitted ampere rating or setting of the overcurrent device, with standard ratings of 15, 20, 30, 40, and 50 amperes.',
          ),
          NECContentSection(
            title: '210.19 Conductors — Minimum Ampacity and Size',
            text: 'Branch-circuit conductors shall have an ampacity not less than the maximum load to be served and not less than specified in various parts of this section.',
          ),
          NECContentSection(
            title: '210.20 Overcurrent Protection',
            text: 'Branch-circuit conductors and equipment shall be protected by overcurrent protective devices that have a rating or setting not exceeding that specified in various parts of this section.',
          ),
        ],
        peExamNotes: 'Branch circuits are a fundamental PE exam topic. Focus on required circuits for specific occupancies, GFCI/AFCI requirements, and calculating loads.',
      ),
      NECArticle(
        number: '215',
        title: 'Feeders',
        chapter: 2,
        summary: 'Minimum size and ampacity of feeders supplying branch circuits.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '215.1 Scope',
            text: 'This article covers requirements for feeders.',
          ),
          NECContentSection(
            title: '215.2 Minimum Rating and Size',
            text: 'Feeder conductors shall have an ampacity not less than required to supply the load as calculated in Parts III, IV, and V of Article 220.',
          ),
          NECContentSection(
            title: '215.3 Overcurrent Protection',
            text: 'Feeders shall be protected against overcurrent in accordance with the provisions of Part I of Article 240.',
          ),
        ],
        peExamNotes: 'Distinguish between feeders and branch circuits. Know how to calculate feeder loads and apply demand factors. Coordinate with Articles 220 and 240.',
      ),
      NECArticle(
        number: '220',
        title: 'Branch-Circuit, Feeder, and Service Load Calculations',
        chapter: 2,
        summary: 'Methods for calculating branch-circuit, feeder, and service loads.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '220.1 Scope',
            text: 'This article provides requirements for calculating branch-circuit, feeder, and service loads.',
          ),
          NECContentSection(
            title: '220.12 Lighting Load for Specified Occupancies',
            text: 'Provides minimum lighting loads for various occupancies in volt-amperes per square foot or square meter.',
          ),
          NECContentSection(
            title: '220.18 Maximum Loads',
            text: 'The total load shall not exceed the rating of the branch circuit, and it shall not exceed the maximum loads specified in various parts of this section.',
          ),
          NECContentSection(
            title: '220.40 General',
            text: 'The calculated load of a feeder or service shall not be less than the sum of the loads on the branch circuits supplied.',
          ),
        ],
        peExamNotes: 'Critical for calculations. Know how to apply demand factors, calculate continuous and noncontinuous loads, and determine minimum lighting and receptacle loads.',
      ),
      NECArticle(
        number: '230',
        title: 'Services',
        chapter: 2,
        summary: 'Installation requirements for services.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '230.1 Scope',
            text: 'This article covers service conductors and equipment for control and protection of services and their installation requirements.',
          ),
          NECContentSection(
            title: '230.24 Clearances',
            text: 'Service-drop conductors shall have specific clearances from ground, buildings, and other structures as specified in this section.',
          ),
          NECContentSection(
            title: '230.70 General',
            text: 'The service disconnecting means shall be installed at a readily accessible location either outside of a building or structure or inside nearest the point of entrance of the service conductors.',
          ),
        ],
        peExamNotes: 'Know service entrance requirements, clearances, and disconnecting means. Rules for service conductor sizing and protection are frequently tested.',
      ),
      NECArticle(
        number: '240',
        title: 'Overcurrent Protection',
        chapter: 2,
        summary: 'Requirements for overcurrent protection and overcurrent protective devices.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '240.1 Scope',
            text: 'This article provides the general requirements for overcurrent protection and overcurrent protective devices.',
          ),
          NECContentSection(
            title: '240.4 Protection of Conductors',
            text: 'Conductors, other than flexible cords, flexible cables, and fixture wires, shall be protected against overcurrent in accordance with their ampacities specified in 310.15, unless otherwise permitted or required in sections (A) through (G).',
          ),
          NECContentSection(
            title: '240.6 Standard Ampere Ratings',
            text: 'Lists the standard ampere ratings for fuses and inverse time circuit breakers.',
          ),
        ],
        peExamNotes: 'Essential for understanding conductor protection. Know the standard ratings, how to select overcurrent devices, and special rules for small conductors and motor circuits.',
      ),
      NECArticle(
        number: '250',
        title: 'Grounding and Bonding',
        chapter: 2,
        summary: 'General requirements for grounding and bonding of electrical installations.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '250.1 Scope',
            text: 'This article covers general requirements for grounding and bonding of electrical installations.',
          ),
          NECContentSection(
            title: '250.4 General Requirements for Grounding and Bonding',
            text: 'Provides the general requirements for grounding and bonding electrical systems, including both grounded systems and ungrounded systems.',
          ),
          NECContentSection(
            title: '250.50 Grounding Electrode System',
            text: 'All grounding electrodes described in 250.52(A)(1) through (A)(7) that are present at each building or structure served shall be bonded together to form the grounding electrode system.',
          ),
          NECContentSection(
            title: '250.66 Size of Alternating-Current Grounding Electrode Conductor',
            text: 'The size of the grounding electrode conductor shall not be less than given in Table 250.66.',
          ),
        ],
        peExamNotes: 'Frequently tested. Understand system vs. equipment grounding, sizing of grounding conductors, and bonding requirements. Know when specific grounding electrodes are required.',
      ),
      
      // Chapter 3: Wiring Methods and Materials
      NECArticle(
        number: '310',
        title: 'Conductors for General Wiring',
        chapter: 3,
        summary: 'Requirements for conductors, including ampacities, insulation types, and applications.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '310.1 Scope',
            text: 'This article covers general requirements for conductors and their type designations, insulations, markings, mechanical strengths, ampacity ratings, and uses.',
          ),
          NECContentSection(
            title: '310.15 Ampacities for Conductors Rated 0–2000 Volts',
            text: 'Provides ampacity tables and adjustment factors for conductors based on installation conditions.',
          ),
          NECContentSection(
            title: 'Table 310.15(B)(16)',
            text: 'Provides the allowable ampacities of insulated conductors rated up to and including 2000 volts, based on ambient temperature of 30°C (86°F).',
          ),
        ],
        peExamNotes: 'Critical for conductor selection. Know how to apply correction and adjustment factors for temperature, conduit fill, and continuous loads. Tables in 310.15 are essential.',
      ),
      NECArticle(
        number: '314',
        title: 'Outlet, Device, Pull, and Junction Boxes; Conduit Bodies; Fittings; and Handhole Enclosures',
        chapter: 3,
        summary: 'Requirements for boxes, conduit bodies, and fittings.',
        isKeyArticle: false,
        content: [
          NECContentSection(
            title: '314.1 Scope',
            text: 'This article covers the installation and use of all boxes and conduit bodies used as outlet, device, junction, or pull boxes, and handhole enclosures.',
          ),
          NECContentSection(
            title: '314.16 Number of Conductors in Outlet, Device, and Junction Boxes, and Conduit Bodies',
            text: 'Provides box fill calculations based on the volume required for conductors, devices, supports, and fittings.',
          ),
        ],
        peExamNotes: 'Know how to calculate box fill based on the number and size of conductors. Understand depth requirements for devices and box support requirements.',
      ),
      
      // Chapter 4: Equipment for General Use
      NECArticle(
        number: '430',
        title: 'Motors, Motor Circuits, and Controllers',
        chapter: 4,
        summary: 'Requirements for motors, motor branch circuits, feeders, control circuits, and motor control centers.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '430.1 Scope',
            text: 'This article covers motors, motor branch-circuit and feeder conductors and their protection, motor overload protection, motor control circuits, motor controllers, and motor control centers.',
          ),
          NECContentSection(
            title: '430.6 Ampacity and Motor Rating Determination',
            text: 'Specifies that motor current ratings shall be used to determine ampacity of conductors, switch ratings, and branch-circuit overcurrent protection.',
          ),
          NECContentSection(
            title: '430.22 Single Motor',
            text: 'Conductors that supply a single motor shall have an ampacity not less than 125 percent of the motor full-load current rating.',
          ),
          NECContentSection(
            title: '430.32 Continuous-Duty Motors',
            text: 'Provides requirements for motor overload protection based on motor type and size.',
          ),
        ],
        peExamNotes: 'Comprehensive understanding of motor circuit sizing is essential for the PE exam. Know how to size branch-circuit conductors, overload protection, short-circuit and ground-fault protection, and control circuits.',
      ),
      NECArticle(
        number: '450',
        title: 'Transformers and Transformer Vaults',
        chapter: 4,
        summary: 'Requirements for transformers, including overcurrent protection and installation.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '450.1 Scope',
            text: 'This article covers the installation of all transformers.',
          ),
          NECContentSection(
            title: '450.3 Overcurrent Protection',
            text: 'Provides requirements for overcurrent protection of transformers, including primary and secondary protection based on transformer type and size.',
          ),
          NECContentSection(
            title: '450.9 Ventilation',
            text: 'Transformer ventilation shall be adequate to dispose of the transformer full-load losses without creating a temperature rise that exceeds the transformer rating.',
          ),
        ],
        peExamNotes: 'Focus on transformer overcurrent protection requirements in Table 450.3(A) and (B). Understand the difference between primary-only, secondary-only, and primary-secondary protection schemes.',
      ),
      
      // Chapter 6: Special Equipment
      NECArticle(
        number: '695',
        title: 'Fire Pumps',
        chapter: 6,
        summary: 'Requirements for electrical installations of fire pumps.',
        isKeyArticle: false,
        content: [
          NECContentSection(
            title: '695.1 Scope',
            text: 'This article covers the installation of electric power sources and interconnecting circuits for fire pumps.',
          ),
          NECContentSection(
            title: '695.4 Continuity of Power',
            text: 'Covers requirements for reliable power sources and transfer equipment for fire pumps.',
          ),
          NECContentSection(
            title: '695.6 Power Wiring',
            text: 'Provides requirements for power wiring for fire pumps, including protection from fire, fault tolerance, and conductor sizing.',
          ),
        ],
        peExamNotes: 'Fire pump installations are a specialized topic that appears on the PE exam. Understand the requirements for reliable power, overcurrent protection, and wiring methods.',
      ),
    ]);
  }
  
  List<NECArticle> _getKeyArticles() {
    return _allArticles.where((article) => article.isKeyArticle).toList();
  }
  
  void _filterArticles() {
    if (_searchQuery.isEmpty && _selectedChapterIndex == -1 && _showKeyArticles) {
      _filteredArticles = _getKeyArticles();
      return;
    }
    
    _filteredArticles = _allArticles.where((article) {
      // Filter by search query
      bool matchesSearch = _searchQuery.isEmpty || 
        article.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        article.summary.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by chapter
      bool matchesChapter = _selectedChapterIndex == -1 || article.chapter == _selectedChapterIndex;
      
      // Filter by key article status
      bool matchesKeyStatus = !_showKeyArticles || article.isKeyArticle;
      
      return matchesSearch && matchesChapter && matchesKeyStatus;
    }).toList();
  }
  
  void _toggleBookmark(NECArticle article) {
    setState(() {
      if (_isBookmarked(article)) {
        _bookmarkedArticles.removeWhere((a) => a.number == article.number);
      } else {
        _bookmarkedArticles.add(article);
      }
    });
  }
  
  bool _isBookmarked(NECArticle article) {
    return _bookmarkedArticles.any((a) => a.number == article.number);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search NEC articles...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterArticles();
                  });
                },
              )
            : Text('NEC Reference Guide'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                  _filterArticles();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          tabs: [
            Tab(text: 'Browse'),
            Tab(text: 'Bookmarks'),
            Tab(text: 'PE Exam Notes'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // Tab 1: Browse Articles
          Column(
            children: [
              // Filter controls
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedChapterIndex,
                            decoration: InputDecoration(
                              labelText: 'Chapter',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: List.generate(_chapterTitles.length, (index) {
                              return DropdownMenuItem<int>(
                                value: index == 0 ? -1 : index,
                                child: Text(_chapterTitles[index]),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedChapterIndex = value!;
                                _filterArticles();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _showKeyArticles,
                              onChanged: (value) {
                                setState(() {
                                  _showKeyArticles = value!;
                                  _filterArticles();
                                });
                              },
                            ),
                            Text('Key Articles Only'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Article list
              Expanded(
                child: _filteredArticles.isEmpty
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
                              'No articles found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return _buildArticleItem(article);
                        },
                      ),
              ),
            ],
          ),
          
          // Tab 2: Bookmarked Articles
          _bookmarkedArticles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No bookmarked articles yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon on any article to save it here',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _bookmarkedArticles.length,
                  itemBuilder: (context, index) {
                    final article = _bookmarkedArticles[index];
                    return _buildArticleItem(article);
                  },
                ),
          
          // Tab 3: PE Exam Notes
          _buildPEExamNotesTab(),
        ],
      ),
    );
  }
  
  Widget _buildArticleItem(NECArticle article) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                article.number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (article.isKeyArticle)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'KEY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(article.summary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isBookmarked(article) ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked(article) ? Colors.amber : null,
              ),
              onPressed: () => _toggleBookmark(article),
              tooltip: 'Bookmark',
            ),
            Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content sections
                ...article.content.map((section) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(section.text),
                        SizedBox(height: 16),
                      ],
                    )),
                
                // PE exam notes
                if (article.peExamNotes.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
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
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              color: Colors.blue.shade800,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'PE Exam Note:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(article.peExamNotes),
                      ],
                    ),
                  ),
                ],
                
                // Action buttons
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // In a real app, this would open the official NEC text
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening official NEC text...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(Icons.open_in_new),
                      label: Text('View Official Text'),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Copy article reference to clipboard
                        Clipboard.setData(ClipboardData(
                          text: 'NEC Article ${article.number}: ${article.title}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Article reference copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Copy Reference'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPEExamNotesTab() {
    // Get all articles with PE exam notes
    final articlesWithNotes = _allArticles
        .where((article) => article.peExamNotes.isNotEmpty)
        .toList();
    
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Card(
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEC for PE Power Exam',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Key articles and concepts frequently tested',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'The PE Power exam frequently tests understanding of NEC requirements, especially in areas of conductor sizing, overcurrent protection, grounding, and motor circuits. Review these key articles carefully.',
                ),
                SizedBox(height: 8),
                Text(
                  'Tip: Articles marked "KEY" are most commonly tested and should be prioritized in your studies.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Articles by Exam Topic:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        
        // Conductors and Wiring
        _buildExamTopicSection(
          'Conductors & Wiring',
          articlesWithNotes.where((a) => 
            a.number == '310' || 
            a.number == '240' || 
            a.number == '110').toList(),
        ),
        
        // Branch Circuits and Feeders
        _buildExamTopicSection(
          'Branch Circuits & Feeders',
          articlesWithNotes.where((a) => 
            a.number == '210' || 
            a.number == '215' || 
            a.number == '220').toList(),
        ),
        
        // Grounding and Protection
        _buildExamTopicSection(
          'Grounding & Protection',
          articlesWithNotes.where((a) => 
            a.number == '250' || 
            a.number == '240').toList(),
        ),
        
        // Motors and Transformers
        _buildExamTopicSection(
          'Motors & Transformers',
          articlesWithNotes.where((a) => 
            a.number == '430' || 
            a.number == '450').toList(),
        ),
      ],
    );
  }
  
  Widget _buildExamTopicSection(String title, List<NECArticle> articles) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...articles.map((article) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.number,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(article.title),
                  subtitle: Text(
                    article.peExamNotes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Open the article detail
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.6,
                        maxChildSize: 0.9,
                        minChildSize: 0.3,
                        expand: false,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          article.number,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          article.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isBookmarked(article) ? Icons.bookmark : Icons.bookmark_border,
                                          color: _isBookmarked(article) ? Colors.amber : null,
                                        ),
                                        onPressed: () => _toggleBookmark(article),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(height: 8),
                                  Text(
                                    'PE Exam Note:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(article.peExamNotes),
                                  SizedBox(height: 16),
                                  Divider(),
                                  SizedBox(height: 8),
                                  Text(
                                    'Article Content:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...article.content.map((section) => Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            section.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(section.text),
                                          SizedBox(height: 16),
                                        ],
                                      )),
                                  SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.close),
                                    label: Text('Close'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About NEC Reference'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is a simplified reference guide to the National Electrical Code (NEC) focused on the most important articles for the PE Power exam.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Tips:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Articles marked "KEY" are most relevant for the exam'),
            Text('• Use the bookmarks tab to save important articles'),
            Text('• Refer to the PE Exam Notes tab for exam-specific guidance'),
            SizedBox(height: 16),
            Text(
              'Disclaimer: For exam preparation only. Always refer to the official NEC for code compliance.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class NECArticle {
  final String number;
  final String title;
  final int chapter;
  final String summary;
  final bool isKeyArticle;
  final List<NECContentSection> content;
  final String peExamNotes;
  
  NECArticle({
    required this.number,
    required this.title,
    required this.chapter,
    required this.summary,
    required this.isKeyArticle,
    required this.content,
    this.peExamNotes = '',
  });
}

class NECContentSection {
  final String title;
  final String text;
  
  NECContentSection({
    required this.title,
    required this.text,
  });
}// lib/screens/nec_reference_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NECReferenceScreen extends StatefulWidget {
  const NECReferenceScreen({super.key});

  @override
  NECReferenceScreenState createState() => NECReferenceScreenState();
}

class NECReferenceScreenState extends State<NECReferenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showKeyArticles = true;
  final List<NECArticle> _allArticles = [];
  List<NECArticle> _filteredArticles = [];
  List<NECArticle> _bookmarkedArticles = [];
  int _selectedChapterIndex = -1; // -1 means "All Chapters"
  List<String> _chapterTitles = [];
  bool _isSearching = false;
  
  // Tabs
  int _currentTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeNECData();
    _filteredArticles = _getKeyArticles();
  }
  
  void _initializeNECData() {
    // In a real app, this would be loaded from a database or API
    // This is a simplified representation of NEC for demo purposes
    
    // Create chapters
    _chapterTitles = [
      'All Chapters',
      '1: General',
      '2: Wiring and Protection',
      '3: Wiring Methods and Materials',
      '4: Equipment for General Use',
      '5: Special Occupancies',
      '6: Special Equipment',
      '7: Special Conditions',
      '8: Communications Systems',
      '9: Tables',
    ];
    
    // Create articles for different chapters
    _allArticles.addAll([
      // Chapter 1: General
      NECArticle(
        number: '100',
        title: 'Definitions',
        chapter: 1,
        summary: 'Contains definitions of terms used throughout the code.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '100.1 Scope',
            text: 'This article contains definitions essential to the proper application of this Code. It does not include commonly defined general terms or commonly defined technical terms from related codes and standards.',
          ),
          NECContentSection(
            title: '100.2 Definitions',
            text: 'The definitions in this section apply to the entire code and include terms like Accessible, Ampacity, Branch Circuit, Circuit Breaker, Conductor, etc.',
          ),
        ],
        peExamNotes: 'Critical for understanding terminology used in NEC. Knowing definitions is essential for the PE exam as they set the foundation for code interpretation.',
      ),
      NECArticle(
        number: '110',
        title: 'Requirements for Electrical Installations',
        chapter: 1,
        summary: 'General requirements for electrical installations including approvals, markings, conductors, and connections.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '110.1 Scope',
            text: 'This article covers general requirements for the examination and approval, installation and use, access to and spaces about electrical conductors and equipment.',
          ),
          NECContentSection(
            title: '110.3 Examination, Identification, Installation, Use, and Listing',
            text: 'Requires that electrical equipment be listed for the purpose when available, suitable for installation according to the code, and installed according to any instructions included in the listing or labeling.',
          ),
          NECContentSection(
            title: '110.12 Mechanical Execution of Work',
            text: 'Electrical equipment shall be installed in a neat and workmanlike manner.',
          ),
          NECContentSection(
            title: '110.14 Electrical Connections',
            text: 'Covers requirements for electrical connections, including provisions for aluminum conductors and temperature limitations.',
          ),
        ],
        peExamNotes: 'Pay special attention to 110.14 for temperature ratings of conductors and terminal ratings. A frequent exam topic is determining the ampacity of conductors based on termination temperature limitations.',
      ),
      
      // Chapter 2: Wiring and Protection
      NECArticle(
        number: '210',
        title: 'Branch Circuits',
        chapter: 2,
        summary: 'Requirements for branch circuits including classifications, required outlets, and loads.',
        isKeyArticle: true,
        content: [
          NECContentSection(
            title: '210.1 Scope',
            text: 'This article covers branch circuits except for branch circuits that supply only motor loads, which are covered in Article 430.',
          ),
          NECContentSection(
            title: '210.3 Rating',
            text: 'Branch circuits shall be rated in accordance with the maximum permitted ampere rating or setting of the overcurrent device, with standard ratings of 15, 20, 30, 40, and 50 amperes.',
          ),
          NECContentSection(
            title: '210.19 Conductors — Minimum Ampacity and Size',
            text: 'Branch-circuit conductors shall have an ampacity not less than the maximum load to be served and not less than specified in various parts of this section.',
          ),
          NECContentSection(
            title: '210.20 Overcurrent Protection',
            text: 'Branch-circuit conductors and equipment shall be 