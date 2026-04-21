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
      if (currentIndex < widget.selectedRules.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0; // Wrap to start
      }
      showAnswer = false;
    });
  }

  void _previousCard() {
    if (widget.selectedRules.isEmpty) return;
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = widget.selectedRules.length - 1; // Wrap to end
      }
      showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safety check if list becomes empty due to removals
    if (widget.selectedRules.isEmpty) {
      return const Scaffold(body: Center(child: Text("All rules removed from session.")));
    }

    final currentRule = widget.selectedRules[currentIndex];

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
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAnswer ? currentRule.description : currentRule.words,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: showAnswer ? 24 : 70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 50),
                      IconButton(
                        iconSize: 90,
                        icon: Icon(
                          showAnswer ? Icons.refresh : Icons.play_circle_fill,
                          color: const Color(0xFF673AB7),
                        ),
                        onPressed: () => setState(() => showAnswer = !showAnswer),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statusRadio('Not Known', Colors.black, currentRule),
                          _statusRadio('Needs Work', Colors.black, currentRule),
                          _statusRadio('Known', Colors.black, currentRule),
                          _statusRadio('Removed', Colors.red, currentRule),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navButton('Previous', _previousCard),
                      const SizedBox(width: 20),
                      _navButton('Next', _nextCard),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.redAccent, 
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
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

  Widget _statusRadio(String label, Color textColor, RuleModel rule) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: rule.knowledgeLevel,
          activeColor: label == 'Removed' ? Colors.red : Colors.black,
          onChanged: (String? value) {
            setState(() {
              rule.knowledgeLevel = value!;
              
              // IF REMOVED: Remove from current session list immediately
              if (rule.knowledgeLevel == 'Removed') {
                widget.selectedRules.removeAt(currentIndex);
                
                if (widget.selectedRules.isEmpty) {
                  Navigator.pop(context); // Go home if no cards left
                } else {
                  // Adjust index if we removed the last item in the list
                  if (currentIndex >= widget.selectedRules.length) {
                    currentIndex = 0;
                  }
                  showAnswer = false;
                }
              }
            });
          },
        ),
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 11),
        ),
      ],
    );
  }

  Widget _navButton(String label, VoidCallback action) {
    return SizedBox(
      width: 160,
      height: 50,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}