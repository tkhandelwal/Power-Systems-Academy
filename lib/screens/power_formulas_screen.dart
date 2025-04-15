// lib/screens/power_formulas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PowerFormulasScreen extends StatefulWidget {
  const PowerFormulasScreen({super.key});

  @override
  PowerFormulasScreenState createState() => PowerFormulasScreenState();
}

class PowerFormulasScreenState extends State<PowerFormulasScreen> {
  late TextEditingController _searchController;
  List<FormulaCategory> _allCategories = [];
  List<FormulaCategory> _filteredCategories = [];
  
  // Create a list of formula categories and their formulas
  void _initializeFormulas() {
    _allCategories = [
      FormulaCategory(
        name: 'Power & Energy',
        formulas: [
          Formula(
            name: 'Three-Phase Power',
            equation: 'P = √3 × VL × IL × cos φ',
            variables: [
              'P = active power (W)',
              'VL = line-to-line voltage (V)',
              'IL = line current (A)',
              'cos φ = power factor'
            ],
            notes: 'For balanced three-phase systems',
          ),
          Formula(
            name: 'Reactive Power',
            equation: 'Q = √3 × VL × IL × sin φ',
            variables: [
              'Q = reactive power (VAR)',
              'VL = line-to-line voltage (V)',
              'IL = line current (A)',
              'sin φ = reactive factor'
            ],
            notes: 'For balanced three-phase systems',
          ),
          Formula(
            name: 'Apparent Power',
            equation: 'S = √3 × VL × IL',
            variables: [
              'S = apparent power (VA)',
              'VL = line-to-line voltage (V)',
              'IL = line current (A)'
            ],
            notes: 'For balanced three-phase systems',
          ),
          Formula(
            name: 'Power Factor',
            equation: 'PF = cos φ = P / S',
            variables: [
              'PF = power factor',
              'P = active power (W)',
              'S = apparent power (VA)',
              'φ = phase angle between voltage and current'
            ],
            notes: 'Power factor is the ratio of active power to apparent power',
          ),
          Formula(
            name: 'Energy',
            equation: 'E = P × t',
            variables: [
              'E = energy (Wh)',
              'P = power (W)',
              't = time (h)'
            ],
            notes: 'Energy is the integral of power over time',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Voltage & Current',
        formulas: [
          Formula(
            name: 'Delta-Wye Voltage Conversion',
            equation: 'VL-L = √3 × VL-N',
            variables: [
              'VL-L = line-to-line voltage',
              'VL-N = line-to-neutral voltage'
            ],
            notes: 'For balanced wye (star) connected systems',
          ),
          Formula(
            name: 'Delta-Wye Current Conversion',
            equation: 'IL = √3 × IP',
            variables: [
              'IL = line current',
              'IP = phase current'
            ],
            notes: 'For delta-connected systems',
          ),
          Formula(
            name: 'Voltage Drop (Three-Phase)',
            equation: 'Vdrop = √3 × I × (R cos φ + X sin φ) × L',
            variables: [
              'Vdrop = voltage drop (V)',
              'I = current (A)',
              'R = resistance per unit length (Ω/m)',
              'X = reactance per unit length (Ω/m)',
              'L = conductor length (m)',
              'φ = phase angle'
            ],
            notes: 'Applies to three-phase balanced circuits',
          ),
          Formula(
            name: 'Current Calculation from Power',
            equation: 'I = P / (√3 × VL × PF)',
            variables: [
              'I = current (A)',
              'P = active power (W)',
              'VL = line-to-line voltage (V)',
              'PF = power factor'
            ],
            notes: 'For three-phase balanced systems',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Transformers',
        formulas: [
          Formula(
            name: 'Transformer Turns Ratio',
            equation: 'a = N₁/N₂ = V₁/V₂ = I₂/I₁',
            variables: [
              'a = turns ratio',
              'N₁, N₂ = number of turns in primary and secondary',
              'V₁, V₂ = primary and secondary voltages',
              'I₁, I₂ = primary and secondary currents'
            ],
            notes: 'Fundamental transformer relationship',
          ),
          Formula(
            name: 'Transformer Efficiency',
            equation: 'η = (Pout / Pin) × 100%',
            variables: [
              'η = efficiency (%)',
              'Pout = output power (W)',
              'Pin = input power (W)'
            ],
            notes: 'Pin includes core losses, copper losses, and output power',
          ),
          Formula(
            name: 'Transformer Regulation',
            equation: 'Reg = ((VNL - VFL) / VFL) × 100%',
            variables: [
              'Reg = voltage regulation (%)',
              'VNL = no-load voltage',
              'VFL = full-load voltage'
            ],
            notes: 'Measure of voltage drop from no-load to full-load',
          ),
          Formula(
            name: 'Transformer Impedance (pu)',
            equation: 'Z(pu) = Z / Zbase',
            variables: [
              'Z(pu) = impedance in per-unit',
              'Z = actual impedance (Ω)',
              'Zbase = base impedance = V²base / Sbase'
            ],
            notes: 'Per-unit system simplifies transformer calculations',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Power System Analysis',
        formulas: [
          Formula(
            name: 'Base Impedance Calculation',
            equation: 'Zbase = kV²base / MVAbase',
            variables: [
              'Zbase = base impedance (Ω)',
              'kVbase = base voltage (kV)',
              'MVAbase = base power (MVA)'
            ],
            notes: 'Used in per-unit system calculations',
          ),
          Formula(
            name: 'Fault Current (Three-Phase)',
            equation: 'If = Vbase / Ztotal',
            variables: [
              'If = fault current (A or pu)',
              'Vbase = base voltage (V or 1.0 pu)',
              'Ztotal = total impedance to fault (Ω or pu)'
            ],
            notes: 'Applies to symmetrical three-phase faults',
          ),
          Formula(
            name: 'Fault MVA',
            equation: 'MVAF = √3 × kV × kA',
            variables: [
              'MVAF = fault level (MVA)',
              'kV = system voltage (kV)',
              'kA = fault current (kA)'
            ],
            notes: 'Represents the severity of a fault',
          ),
          Formula(
            name: 'Thevenin Equivalent Impedance',
            equation: 'Zth = Voc / Isc',
            variables: [
              'Zth = Thevenin equivalent impedance (Ω)',
              'Voc = open-circuit voltage (V)',
              'Isc = short-circuit current (A)'
            ],
            notes: 'Simplifies complex network analysis',
          ),
          Formula(
            name: 'Power Transfer',
            equation: 'P = (V₁ × V₂ × sin δ) / X',
            variables: [
              'P = active power transferred (W)',
              'V₁, V₂ = sending and receiving end voltages (V)',
              'δ = power angle (rad)',
              'X = reactance between nodes (Ω)'
            ],
            notes: 'Applies to lossless transmission lines',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Motors & Generators',
        formulas: [
          Formula(
            name: 'Synchronous Speed',
            equation: 'ns = (120 × f) / p',
            variables: [
              'ns = synchronous speed (rpm)',
              'f = frequency (Hz)',
              'p = number of poles'
            ],
            notes: 'Applies to synchronous machines and induction motors',
          ),
          Formula(
            name: 'Slip',
            equation: 's = (ns - nr) / ns',
            variables: [
              's = slip',
              'ns = synchronous speed (rpm)',
              'nr = rotor speed (rpm)'
            ],
            notes: 'Measure of how much an induction motor lags synchronous speed',
          ),
          Formula(
            name: 'Motor Efficiency',
            equation: 'η = (Pout / Pin) × 100%',
            variables: [
              'η = efficiency (%)',
              'Pout = mechanical output power (W)',
              'Pin = electrical input power (W)'
            ],
            notes: 'Mechanical power output divided by electrical power input',
          ),
          Formula(
            name: 'Motor Torque',
            equation: 'T = (P × 9.55) / n',
            variables: [
              'T = torque (N·m)',
              'P = power (W)',
              'n = speed (rpm)'
            ],
            notes: '9.55 is the conversion factor from W/rpm to N·m',
          ),
          Formula(
            name: 'Motor Starting Current',
            equation: 'Istart = LRC × Irated',
            variables: [
              'Istart = starting current (A)',
              'LRC = locked rotor current multiple',
              'Irated = rated full load current (A)'
            ],
            notes: 'LRC typically 5-7 times rated current for induction motors',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Power Distribution',
        formulas: [
          Formula(
            name: 'Conductor Resistance',
            equation: 'R = ρ × L / A',
            variables: [
              'R = resistance (Ω)',
              'ρ = resistivity (Ω·m)',
              'L = length (m)',
              'A = cross-sectional area (m²)'
            ],
            notes: 'Temperature affects resistivity',
          ),
          Formula(
            name: 'Ampacity Correction Factor',
            equation: 'Ia = Ib × CF₁ × CF₂ × ... × CFn',
            variables: [
              'Ia = adjusted ampacity',
              'Ib = base ampacity',
              'CF = correction factors'
            ],
            notes: 'Correction factors for temperature, depth, grouping, etc.',
          ),
          Formula(
            name: 'Voltage Drop Percentage',
            equation: 'VD% = (Vdrop / Vsource) × 100%',
            variables: [
              'VD% = voltage drop percentage',
              'Vdrop = voltage drop (V)',
              'Vsource = source voltage (V)'
            ],
            notes: 'Should typically be ≤ 3% for feeders, ≤ 5% total',
          ),
          Formula(
            name: 'Power Loss in Conductor',
            equation: 'Ploss = I² × R',
            variables: [
              'Ploss = power loss (W)',
              'I = current (A)',
              'R = resistance (Ω)'
            ],
            notes: 'I²R losses increase with the square of current',
          ),
        ],
      ),
      FormulaCategory(
        name: 'Protection & Grounding',
        formulas: [
          Formula(
            name: 'CT Ratio Calculation',
            equation: 'CTR = Iprimary / Isecondary',
            variables: [
              'CTR = current transformer ratio',
              'Iprimary = primary current (A)',
              'Isecondary = secondary current (A)'
            ],
            notes: 'Standard secondary currents are 1A or 5A',
          ),
          Formula(
            name: 'Relay Pickup Current',
            equation: 'Ipickup = PSM × CT secondary rating',
            variables: [
              'Ipickup = relay pickup current (A)',
              'PSM = plug setting multiplier',
              'CT secondary rating = typically 1A or 5A'
            ],
            notes: 'PSM is set based on protection requirements',
          ),
          Formula(
            name: 'Ground Resistance',
            equation: 'Rg = ρ / (2π × L)',
            variables: [
              'Rg = ground resistance (Ω)',
              'ρ = soil resistivity (Ω·m)',
              'L = electrode length (m)'
            ],
            notes: 'Simplified formula for single rod electrode',
          ),
          Formula(
            name: 'Step Voltage',
            equation: 'Estep = (ρ × Is × Ks) / L',
            variables: [
              'Estep = step voltage (V)',
              'ρ = soil resistivity (Ω·m)',
              'Is = fault current (A)',
              'Ks = step voltage coefficient',
              'L = grounding system length (m)'
            ],
            notes: 'Critical for safety in substation design',
          ),
        ],
      ),
    ];
    
    _filteredCategories = List.from(_allCategories);
  }
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeFormulas();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterFormulas(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = List.from(_allCategories);
      });
      return;
    }
    
    query = query.toLowerCase();
    
    setState(() {
      _filteredCategories = _allCategories
          .map((category) {
            // Create a new category with filtered formulas
            return FormulaCategory(
              name: category.name,
              formulas: category.formulas
                  .where((formula) =>
                      formula.name.toLowerCase().contains(query) ||
                      formula.equation.toLowerCase().contains(query) ||
                      formula.variables.any((variable) => variable.toLowerCase().contains(query)) ||
                      formula.notes.toLowerCase().contains(query))
                  .toList(),
            );
          })
          .where((category) => category.formulas.isNotEmpty)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Power Engineering Formulas'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInformationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search formulas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterFormulas,
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'No formulas found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBookmarkDialog(context);
        },
        child: Icon(Icons.bookmark),
        tooltip: 'View Bookmarked Formulas',
      ),
    );
  }
  
  Widget _buildCategoryCard(FormulaCategory category) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        initiallyExpanded: _searchController.text.isNotEmpty,
        children: category.formulas.map((formula) => _buildFormulaCard(formula)).toList(),
      ),
    );
  }
  
  Widget _buildFormulaCard(Formula formula) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formula.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () {
                    // Bookmark formula
                  },
                  tooltip: 'Bookmark Formula',
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: formula.equation));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Formula copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Copy Formula',
                ),
              ],
            ),
            SizedBox(height: 8),
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.functions,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formula.equation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Where:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            ...formula.variables.map((variable) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• $variable'),
                )),
            if (formula.notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Note: ${formula.notes}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Power Formulas'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This reference contains common formulas used in power engineering. Formulas are organized by category for easy navigation.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Use the search bar to find specific formulas'),
              Text('• Bookmark frequently used formulas for quick access'),
              Text('• Tap the copy icon to copy a formula to clipboard'),
              SizedBox(height: 12),
              Text(
                'Disclaimer: Always verify critical calculations using multiple sources and engineering judgment.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showBookmarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmarked Formulas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('You haven\'t bookmarked any formulas yet.'),
              SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on a formula to save it for quick access.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FormulaCategory {
  final String name;
  final List<Formula> formulas;
  
  FormulaCategory({required this.name, required this.formulas});
}

class Formula {
  final String name;
  final String equation;
  final List<String> variables;
  final String notes;
  
  Formula({
    required this.name,
    required this.equation,
    required this.variables,
    this.notes = '',
  });
}