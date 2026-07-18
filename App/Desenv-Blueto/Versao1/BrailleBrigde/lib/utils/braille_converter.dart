class BrailleConverter {
  static const Map<String, String> _charToBraille = {
    'a': '100000',
    'b': '110000',
    'c': '100100',
    'd': '100110',
    'e': '100010',
    'f': '110100',
    'g': '110110',
    'h': '110010',
    'i': '010100',
    'j': '010110',
    'k': '101000',
    'l': '111000',
    'm': '101100',
    'n': '101110',
    'o': '101010',
    'p': '111100',
    'q': '111110',
    'r': '111010',
    's': '011100',
    't': '011110',
    'u': '101001',
    'v': '111001',
    'w': '010111',
    'x': '101101',
    'y': '101111',
    'z': '101011',
    '1': '100000',
    '2': '110000',
    '3': '100100',
    '4': '100110',
    '5': '100010',
    '6': '110100',
    '7': '110110',
    '8': '110010',
    '9': '010100',
    '0': '010110',
    ' ': '000000',
  };

  static const String _numIndicator = '001111';
  static const String _upperIndicator = '000001';
  static const String _capitalIndicator = '000001';

  static String charToBraille(String char) {
    final lower = char.toLowerCase();
    if (_charToBraille.containsKey(lower)) {
      return _charToBraille[lower]!;
    }
    return '000000';
  }

  static String textToBraille(String text) {
    final buffer = StringBuffer();
    bool lastWasNumber = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isNumber = RegExp(r'[0-9]').hasMatch(char);
      final isLetter = RegExp(r'[a-zA-Z]').hasMatch(char);

      if (isNumber) {
        if (!lastWasNumber) {
          buffer.write(_numIndicator);
          lastWasNumber = true;
        }
        buffer.write(charToBraille(char));
      } else if (isLetter) {
        lastWasNumber = false;
        if (char == char.toUpperCase() && char.toLowerCase() != char) {
          buffer.write(_upperIndicator);
        }
        buffer.write(charToBraille(char));
      } else {
        lastWasNumber = false;
        buffer.write(charToBraille(char));
      }
    }

    return buffer.toString();
  }

  static String brailleToChar(String braille) {
    for (final entry in _charToBraille.entries) {
      if (entry.value == braille) {
        return entry.key;
      }
    }
    return '?';
  }

  static String brailleToText(String braille) {
    final buffer = StringBuffer();
    bool numberMode = false;

    for (int i = 0; i <= braille.length - 6; i += 6) {
      final cell = braille.substring(i, i + 6);

      if (cell == _numIndicator) {
        numberMode = true;
        continue;
      }

      if (cell == _upperIndicator || cell == _capitalIndicator) {
        numberMode = false;
        continue;
      }

      if (numberMode) {
        final numMap = {
          '100000': '1', '110000': '2', '100100': '3', '100110': '4',
          '100010': '5', '110100': '6', '110110': '7', '110010': '8',
          '010100': '9', '010110': '0',
        };
        buffer.write(numMap[cell] ?? '?');
      } else {
        buffer.write(brailleToChar(cell));
      }
    }

    return buffer.toString();
  }
}
