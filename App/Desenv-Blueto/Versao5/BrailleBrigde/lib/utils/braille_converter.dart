class BrailleConverter {
  static const Map<String, String> _charToBraille = {
    'a': '100000', 'b': '110000', 'c': '100100', 'd': '100110',
    'e': '100010', 'f': '110100', 'g': '110110', 'h': '110010',
    'i': '010100', 'j': '010110', 'k': '101000', 'l': '111000',
    'm': '101100', 'n': '101110', 'o': '101010', 'p': '111100',
    'q': '111110', 'r': '111010', 's': '011100', 't': '011110',
    'u': '101001', 'v': '111001', 'w': '010111', 'x': '101101',
    'y': '101111', 'z': '101011',
    '0': '001111', '1': '100000', '2': '110000', '3': '100100',
    '4': '100110', '5': '100010', '6': '110100', '7': '110110',
    '8': '110010', '9': '010100',
    ' ': '000000',
    '.': '010011', ',': '010000', ';': '011000', ':': '011010',
    '!': '011010', '?': '011001', '-': '001001', '/': '001100',
    '(': '010101', ')': '010101',
  };

  static const String _numberIndicator = '001111';
  static const String _uppercaseIndicator = '000001';

  static String charToBraille(String char) {
    char = char.toLowerCase();
    if (_charToBraille.containsKey(char)) {
      return _charToBraille[char]!;
    }
    return '000000';
  }

  static String textToBraille(String text) {
    if (text.isEmpty) return '';

    StringBuffer result = StringBuffer();
    bool numberMode = false;
    bool uppercaseMode = false;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      if (RegExp(r'[0-9]').hasMatch(char)) {
        if (!numberMode) {
          result.write(_numberIndicator);
          numberMode = true;
        }
        result.write(charToBraille(char));
        result.write(' ');
      } else if (char == ' ') {
        result.write(charToBraille(' '));
        result.write(' ');
        numberMode = false;
      } else if (char.toUpperCase() == char && char.toLowerCase() != char) {
        if (!uppercaseMode) {
          result.write(_uppercaseIndicator);
          uppercaseMode = true;
        }
        result.write(charToBraille(char));
        result.write(' ');
      } else {
        if (uppercaseMode) {
          uppercaseMode = false;
        }
        if (numberMode) {
          numberMode = false;
        }
        result.write(charToBraille(char));
        result.write(' ');
      }
    }

    return result.toString().trim();
  }

  static String brailleToChar(String braille) {
    for (var entry in _charToBraille.entries) {
      if (entry.value == braille) {
        return entry.key;
      }
    }
    return '?';
  }

  static String brailleToText(String brailleText) {
    List<String> cells = brailleText.split(' ');
    StringBuffer result = StringBuffer();
    bool numberMode = false;

    for (String cell in cells) {
      if (cell == _numberIndicator) {
        numberMode = true;
        continue;
      }
      if (cell == _uppercaseIndicator) {
        continue;
      }

      String char = brailleToChar(cell);
      if (numberMode && RegExp(r'[a-j]').hasMatch(char)) {
        int index = char.codeUnitAt(0) - 'a'.codeUnitAt(0);
        char = (index).toString();
      }
      result.write(char);
    }

    return result.toString();
  }
}
