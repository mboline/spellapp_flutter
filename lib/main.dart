import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/rules_data.dart';
import 'practice_screen.dart';

void main() {
  runApp(const SpellingRulesApp());
}

class SpellingRulesApp extends StatelessWidget {
  const SpellingRulesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spelling Rules Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Roboto',
        useMaterial3: true,
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
    setState(() {
      isLoaded = true;
    });
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
        const SnackBar(content: Text('Please select at least one rule.')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeScreen(selectedRules: selectedRules),
        ),
      ).then((_) {
        for (var rule in rules) {
          rule.isSelected = false;
        }
        _saveProgress();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Image (No errorBuilder so we can see if it works)
            Image.asset(
              'assets/images/banner.gif',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),

            // 2. Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spelling Rules Flashcards',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Brought to you by ', style: TextStyle(fontSize: 18, color: Colors.black)),
                      const Text(
                        'Phonogram University',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1A237E), // Deep Blue
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  ElevatedButton(
                    onPressed: _startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Start Session',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Thin Horizontal Line
            const Padding(
              padding: EdgeInsets.only(top: 25, bottom: 20),
              child: Divider(thickness: 0.5, color: Colors.grey, height: 1),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose the rules you would like to practice.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            // 4. Rules Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: DataTable(
                columnSpacing: 20,
                columns: [
                  DataColumn(
                    label: StatefulBuilder(
                      builder: (context, setHeaderState) {
                        return Checkbox(
                          value: rules.every((r) => r.isSelected),
                          onChanged: (bool? value) {
                            setHeaderState(() {
                              setState(() {
                                for (var r in rules) {
                                  r.isSelected = value ?? false;
                                  if (r.isSelected && r.knowledgeLevel == 'Removed') {
                                    r.knowledgeLevel = 'Not Known';
                                  }
                                }
                              });
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const DataColumn(label: Text('WORD', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('RULE DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: rules.map((rule) {
                  return DataRow(
                    cells: [
                      DataCell(
                        StatefulBuilder(
                          builder: (context, setCellState) {
                            return Checkbox(
                              value: rule.isSelected,
                              onChanged: (bool? value) {
                                setCellState(() {
                                  rule.isSelected = value ?? false;
                                  if (rule.isSelected && rule.knowledgeLevel == 'Removed') {
                                    rule.knowledgeLevel = 'Not Known';
                                  }
                                });
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                      DataCell(Text(rule.words, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Container(constraints: const BoxConstraints(maxWidth: 500), child: Text(rule.description))),
                      DataCell(_buildStatusBadge(rule.knowledgeLevel)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String level) {
    Color color = Colors.black54;
    if (level == 'Known') color = Colors.green;
    if (level == 'Needs Work') color = Colors.orange;
    if (level == 'Removed') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(level, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}