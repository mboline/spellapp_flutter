class RuleModel {
  final String id;
  final String words;
  final String description;
  bool isSelected;
  String knowledgeLevel; 

  RuleModel({
    required this.id,
    required this.words,
    required this.description,
    this.isSelected = false,
    this.knowledgeLevel = 'Not Known',
  });
}

class RulesData {
  static List<RuleModel> spellingRules = [
    RuleModel(
      id: '1',
      words: 'same, cede, time, lone, pure',
      description: 'Silent final e goes back to make the vowel (a, e, i, o, u) say its own name.',
    ),
    RuleModel(
      id: '2',
      words: 'mason, begin, motor, music',
      description: 'a, e, o, u usually say their long sound at the end of a syllable.',
    ),
    RuleModel(
      id: '3',
      words: 'ma, pa, spa',
      description: 'When a word ends with a, it says its third sound.',
    ),
    RuleModel(
      id: '4',
      words: 'watt, hall',
      description: 'a may say its third sound after a w or before an l.',
    ),
    RuleModel(
      id: '5',
      words: 'chance, charge',
      description: 'The silent e comes at the end of these words to make the c and g say their own second sound.',
    ),
    RuleModel(
      id: '6',
      words: 'chance, icing, icy',
      description: 'c before e, i, or y says "s".',
    ),
    RuleModel(
      id: '7',
      words: 'germ, giant, gym',
      description: 'g before e, i, or y may say "j".',
    ),
    RuleModel(
      id: '8',
      words: 'quiet, quit',
      description: 'letter q is always followed by the letter u, and we say "kw".',
    ),
    RuleModel(
      id: '9',
      words: 'find, bold',
      description: 'Vowels i and o may say long i and long o when followed by two consonants.',
    ),
    RuleModel(
      id: '10',
      words: 'have, blue',
      description: 'English words do not end with v or u. The e is there to cover up the v or u at the end of words.',
    ),
    RuleModel(
      id: '11',
      words: 'little',
      description: 'Silent final e is there because all English syllables must have a written vowel.',
    ),
    RuleModel(
      id: '12',
      words: 'are',
      description: 'This is no job e. It is in the word, but it has no job like the first four do. It is just no job e.',
    ),
    RuleModel(
      id: '13',
      words: 'ball, off, miss',
      description: 'We often double l, f, and s following a single vowel at the end of a one-syllable word.',
    ),
    RuleModel(
      id: '14',
      words: 'berry, marry, furry',
      description: 'y says the long e sound at the end of a multiple syllable word.',
    ),
    RuleModel(
      id: '15',
      words: 'why, my, try',
      description: 'When a one syllable word ends in a single vowel y, it says the long i sound.',
    ),
    RuleModel(
      id: '16',
      words: 'she, wish, friendship',
      description: "Phonogram 'sh' is used at the beginning of a word, at the end of a syllable, but not at the beginning of any syllable after the first one except for the ending ship.",
    ),
    RuleModel(
      id: '17',
      words: 'pack, peck, pick, pock, puck',
      description: "Two-letter 'k' (ck) is used only after a short vowel.",
    ),
    RuleModel(
      id: '18',
      words: 'flooded, parted',
      description: "When ed says 'ed' after words ending with 'd' or 't' they form another syllable.",
    ),
    RuleModel(
      id: '19',
      words: 'loved, wrapped',
      description: "Past tense ending ed says 'd' or 't' at the end of any base word which does not end in the sound 'd' or 't'.",
    ),
    RuleModel(
      id: '20',
      words: 'badge, ledge, ridge, lodge, fudge',
      description: "Three-letter 'j' (dge) is used only after a short vowel.",
    ),
    RuleModel(
      id: '21',
      words: 'catch, fetch, stitch, botch, hutch',
      description: "Three letter 'ch' (tch) is used only after a short vowel.",
    ),
    RuleModel(
      id: '22',
      words: 'nation, mansion, facial',
      description: "ti, si, and ci are used to say 'sh' at the beginning of any syllable after the first one.",
    ),
  ];
}