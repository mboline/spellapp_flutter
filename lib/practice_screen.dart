import 'package:flutter/material.dart';
import 'models/rules_data.dart';

class PracticeScreen extends StatefulWidget {
  final List<RuleModel> selectedRules;
  const PracticeScreen({super.key, required this.selectedRules});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int currentIndex = 0;
  bool showAnswer = false;

  void _nextCard() {
    if (widget.selectedRules.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex < widget.selectedRules.length - 1) ? currentIndex + 1 : 0;
      showAnswer = false;
    });
  }

  void _previousCard() {
    if (widget.selectedRules.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex > 0) ? currentIndex - 1 : widget.selectedRules.length - 1;
      showAnswer = false;
    });
  }

  // Dynamic font scaling to handle long word lists
  double _getAdaptiveFontSize(String text, bool isAnswer, bool isMobile) {
    if (isAnswer) return isMobile ? 18 : 24;
    
    if (text.length > 25) {
      return isMobile ? 26 : 40; 
    } else if (text.length > 15) {
      return isMobile ? 32 : 55;
    }
    
    return isMobile ? 42 : 70;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedRules.isEmpty) {
      return const Scaffold(body: Center(child: Text("All rules removed from session.")));
    }

    final currentRule = widget.selectedRules[currentIndex];
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final String displayText = showAnswer ? currentRule.description : currentRule.words;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Rule ${currentIndex + 1} of ${widget.selectedRules.length}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: isMobile ? screenWidth * 0.95 : screenWidth * 0.8,
                    padding: EdgeInsets.all(isMobile ? 15 : 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _getAdaptiveFontSize(displayText, showAnswer, isMobile),
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        IconButton(
                          iconSize: isMobile ? 60 : 90,
                          icon: Icon(
                            showAnswer ? Icons.refresh : Icons.play_circle_fill,
                            color: const Color(0xFF673AB7),
                          ),
                          onPressed: () => setState(() => showAnswer = !showAnswer),
                        ),
                        const SizedBox(height: 20),
                        const Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        // The Status Radio Grid
                        _buildStatusOptions(currentRule, isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navButton('Previous', _previousCard, isMobile),
                      const SizedBox(width: 15),
                      _navButton('Next', _nextCard, isMobile),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Home', 
                      style: TextStyle(
                        color: Colors.redAccent, 
                        fontWeight: FontWeight.bold, 
                        decoration: TextDecoration.underline
                      )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Creates a 2x2 grid on mobile using Wrap
  Widget _buildStatusOptions(RuleModel rule, bool isMobile) {
    final options = ['Not Known', 'Needs Work', 'Known', 'Removed'];
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isMobile ? 5 : 20,
      runSpacing: 5,
      children: options.map((label) => _statusRadio(label, label == 'Removed' ? Colors.red : Colors.black, rule, isMobile)).toList(),
    );
  }

  Widget _statusRadio(String label, Color textColor, RuleModel rule, bool isMobile) {
    return Container(
      // Forces a roughly 2x2 layout by giving each button half the available width
      width: isMobile ? (MediaQuery.of(context).size.width * 0.42) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tighter touch target
            value: label,
            groupValue: rule.knowledgeLevel,
            activeColor: label == 'Removed' ? Colors.red : Colors.black,
            onChanged: (value) {
              setState(() {
                rule.knowledgeLevel = value!;
                if (rule.knowledgeLevel == 'Removed') {
                  widget.selectedRules.removeAt(currentIndex);
                  if (widget.selectedRules.isEmpty) {
                    Navigator.pop(context);
                  } else {
                    if (currentIndex >= widget.selectedRules.length) currentIndex = 0;
                    showAnswer = false;
                  }
                }
              });
            },
          ),
          Flexible(
            child: Text(
              label, 
              style: TextStyle(color: textColor, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String label, VoidCallback action, bool isMobile) {
    return SizedBox(
      width: isMobile ? 130 : 160,
      height: 45,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}