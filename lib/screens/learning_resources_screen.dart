import 'package:flutter/material.dart';

class LearningResourcesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Learning Resources'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Videos'),
              Tab(text: 'References'),
              Tab(text: 'Formulas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            VideosTab(),
            ReferencesTab(),
            FormulasTab(),
          ],
        ),
      ),
    );
  }
}

class VideosTab extends StatelessWidget {
  final List<Map<String, dynamic>> videoCategories = [
    {
      'title': 'Power System Analysis',
      'videos': [
        {
          'title': 'Introduction to Power Flow Analysis',
          'duration': '32:15',
          'instructor': 'Dr. Sarah Johnson',
          'watched': true,
        },
        {
          'title': 'Solving Load Flow Problems',
          'duration': '45:30',
          'instructor': 'Dr. Sarah Johnson',
          'watched': true,
        },
        {
          'title': 'Fault Analysis Techniques',
          'duration': '38:45',
          'instructor': 'Dr. Sarah Johnson',
          'watched': false,
        },
        {
          'title': 'Power System Stability',
          'duration': '41:20',
          'instructor': 'Dr. Sarah Johnson',
          'watched': false,
        },
      ],
    },
    {
      'title': 'Electrical Equipment',
      'videos': [
        {
          'title': 'Transformer Theory and Operation',
          'duration': '36:50',
          'instructor': 'Prof. Michael Chen',
          'watched': true,
        },
        {
          'title': 'Circuit Breaker Technologies',
          'duration': '29:15',
          'instructor': 'Prof. Michael Chen',
          'watched': false,
        },
        {
          'title': 'Motor Control and Protection',
          'duration': '42:30',
          'instructor': 'Prof. Michael Chen',
          'watched': false,
        },
      ],
    },
    {
      'title': 'Power Transmission',
      'videos': [
        {
          'title': 'Transmission Line Parameters',
          'duration': '33:45',
          'instructor': 'Dr. Emily Rodriguez',
          'watched': false,
        },
        {
          'title': 'HVDC Transmission Systems',
          'duration': '45:10',
          'instructor': 'Dr. Emily Rodriguez',
          'watched': false,
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: videoCategories.length,
      itemBuilder: (context, index) {
        final category = videoCategories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category['title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...List.generate(
              category['videos'].length,
              (i) => VideoCard(
                title: category['videos'][i]['title'],
                duration: category['videos'][i]['duration'],
                instructor: category['videos'][i]['instructor'],
                watched: category['videos'][i]['watched'],
                onTap: () {
                  // Play video
                },
              ),
            ),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String instructor;
  final bool watched;
  final VoidCallback onTap;

  const VideoCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.instructor,
    required this.watched,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      size: 36,
                      color: Colors.white,
                    ),
                    if (watched)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Watched',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
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
                    SizedBox(height: 4),
                    Text(
                      instructor,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferencesTab extends StatelessWidget {
  final List<Map<String, dynamic>> references = [
    {
      'title': 'NFPA 70: National Electrical Code',
      'type': 'Standard',
      'icon': Icons.book,
      'color': Colors.red,
    },
    {
      'title': 'IEEE 1547: Standard for Interconnection and Interoperability',
      'type': 'Standard',
      'icon': Icons.book,
      'color': Colors.blue,
    },
    {
      'title': 'Power System Analysis and Design',
      'type': 'Textbook',
      'icon': Icons.menu_book,
      'color': Colors.green,
    },
    {
      'title': 'Electric Power Distribution Engineering',
      'type': 'Textbook',
      'icon': Icons.menu_book,
      'color': Colors.green,
    },
    {
      'title': 'NESC: National Electrical Safety Code',
      'type': 'Standard',
      'icon': Icons.book,
      'color': Colors.red,
    },
    {
      'title': 'Protective Relaying: Principles and Applications',
      'type': 'Textbook',
      'icon': Icons.menu_book,
      'color': Colors.green,
    },
    {
      'title': 'IEEE Guide for Protective Relay Applications',
      'type': 'Guide',
      'icon': Icons.description,
      'color': Colors.purple,
    },
    {
      'title': 'NFPA 70E: Standard for Electrical Safety in the Workplace',
      'type': 'Standard',
      'icon': Icons.book,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: references.length,
      itemBuilder: (context, index) {
        final reference = references[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: reference['color'].withOpacity(0.2),
              child: Icon(
                reference['icon'],
                color: reference['color'],
              ),
            ),
            title: Text(
              reference['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(reference['type']),
            trailing: IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                // Download reference
              },
            ),
            onTap: () {
              // Open reference
            },
          ),
        );
      },
    );
  }
}

class FormulasTab extends StatelessWidget {
  final List<Map<String, dynamic>> formulaCategories = [
    {
      'title': 'Power System Analysis',
      'formulas': [
        'Complex Power: S = P + jQ',
        'Power Factor: PF = cos(φ)',
        'Real Power: P = VI cos(φ)',
        'Reactive Power: Q = VI sin(φ)',
        'Apparent Power: S = VI',
      ],
    },
    {
      'title': 'Three-Phase Systems',
      'formulas': [
        'Line-to-Line Voltage: VL-L = √3 × VL-N',
        'Phase Voltage (Y): VL-N = VL-L / √3',
        'Three-Phase Power: P = √3 × VL-L × IL × cos(φ)',
        'Three-Phase Reactive Power: Q = √3 × VL-L × IL × sin(φ)',
        'Three-Phase Apparent Power: S = √3 × VL-L × IL',
      ],
    },
    {
      'title': 'Transformers',
      'formulas': [
        'Turns Ratio: a = N1/N2 = V1/V2 = I2/I1',
        'Transformer Efficiency: η = Pout/Pin × 100%',
        'Voltage Regulation: VR = (VNL - VFL)/VFL × 100%',
        'kVA Rating: S = V × I',
        'Impedance: Z = V/I',
      ],
    },
    {
      'title': 'Transmission Lines',
      'formulas': [
        'Inductance per Unit Length: L = (μ0/2π) × ln(D/r)',
        'Capacitance per Unit Length: C = 2πε/ln(D/r)',
        'Characteristic Impedance: Z0 = √(L/C)',
        'Propagation Constant: γ = α + jβ = √(ZY)',
        'Voltage Drop: ΔV = IZ',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: formulaCategories.length,
      itemBuilder: (context, index) {
        final category = formulaCategories[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              category['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List.generate(
                      category['formulas'].length,
                      (i) => FormulaCard(
                        formula: category['formulas'][i],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            // Print formulas
                          },
                          icon: Icon(Icons.print),
                          label: Text('Print'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Download PDF
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FormulaCard extends StatelessWidget {
  final String formula;

  const FormulaCard({
    Key? key,
    required this.formula,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.functions,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                formula,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}