import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/rules_data.dart';
import 'practice_screen.dart';

void main() => runApp(const SpellingRulesApp());

class SpellingRulesApp extends StatelessWidget {
  const SpellingRulesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spelling Rules Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', 
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
      ),
      home: const RuleSelectionScreen(),
    );
  }
}

class RuleSelectionScreen extends StatefulWidget {
  const RuleSelectionScreen({super.key});
  @override
  State<RuleSelectionScreen> createState() => _RuleSelectionScreenState();
}

class _RuleSelectionScreenState extends State<RuleSelectionScreen> {
  late List<RuleModel> rules;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    rules = List.from(RulesData.spellingRules);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var rule in rules) {
      rule.knowledgeLevel = prefs.getString('rule_${rule.id}') ?? 'Not Known';
    }
    setState(() => isLoaded = true);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var rule in rules) {
      await prefs.setString('rule_${rule.id}', rule.knowledgeLevel);
    }
  }

  void _startSession() {
    final selectedRules = rules.where((r) => r.isSelected).toList();
    if (selectedRules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one rule.'))
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PracticeScreen(selectedRules: selectedRules)),
      ).then((_) {
        // Reset checkboxes after session
        for (var rule in rules) rule.isSelected = false;
        _saveProgress();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // FIXED HEADER SECTION (Non-scrolling)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/banner.gif', 
                width: double.infinity, 
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spelling Rules Flashcards',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Brought to you by Phonogram University', 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        decoration: TextDecoration.underline, 
                        color: Color(0xFF1A237E)
                      )
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: isMobile ? double.infinity : 220,
                      child: ElevatedButton(
                        onPressed: _startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          'Start Session', 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 0.5, color: Colors.grey, height: 1),
            ],
          ),

          // SCROLLABLE BODY SECTION
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                    child: Text(
                      'Choose the rules you would like to practice.', 
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: isMobile ? _buildMobileList() : _buildDesktopTable(),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TABLET/DESKTOP TABLE (With Dynamic Height Fix) ---
  Widget _buildDesktopTable() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: DataTable(
        headingRowHeight: 45,
        horizontalMargin: 10,
        columnSpacing: 40,
        dataRowMinHeight: 50,
        dataRowMaxHeight: double.infinity, // Allows row to expand for multi-line words
        columns: [
          DataColumn(label: Checkbox(
            value: rules.every((r) => r.isSelected),
            onChanged: (val) => setState(() {
              for (var r in rules) {
                r.isSelected = val!;
                if (r.isSelected && r.knowledgeLevel == 'Removed') r.knowledgeLevel = 'Not Known';
              }
            }),
          )),
          const DataColumn(label: Text('WORD', style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(label: Text('RULE DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold))),
          const DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: rules.map((rule) => DataRow(cells: [
          DataCell(Checkbox(value: rule.isSelected, onChanged: (val) => setState(() {
            rule.isSelected = val!;
            if (rule.isSelected && rule.knowledgeLevel == 'Removed') rule.knowledgeLevel = 'Not Known';
          }))),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 180), // Prevents cutoff on wide word lists
                child: Text(rule.words, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(rule.description),
              ),
            ),
          ),
          DataCell(_buildStatusBadge(rule.knowledgeLevel)),
        ])).toList(),
      ),
    );
  }

  // --- MOBILE LIST (Stacking logic) ---
  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rule.isSelected,
                        onChanged: (val) => setState(() {
                          rule.isSelected = val!;
                          if (rule.isSelected && rule.knowledgeLevel == 'Removed') rule.knowledgeLevel = 'Not Known';
                        }),
                      ),
                      Expanded(
                        child: Text(
                          rule.words, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                        )
                      ),
                      _buildStatusBadge(rule.knowledgeLevel),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 5, right: 10),
                    child: Text(
                      rule.description, 
                      style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String level) {
    Color color = level == 'Known' ? Colors.green : level == 'Needs Work' ? Colors.orange : level == 'Removed' ? Colors.red : Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Text(level, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}