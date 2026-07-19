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
    '+': '011101',
    '\u00e7': '111001',
    '\u00e1': '111011', '\u00e9': '111111', '\u00ed': '001100',
    '\u00f3': '001101', '\u00fa': '011111', '\u00e0': '011001',
    '\u00e3': '001110', '\u00f5': '010110',
    '\u00e2': '100001', '\u00ea': '110001',
    '\u00f4': '100111', '\u00ec': '000110',
    '\u00f2': '110101', '\u00f9': '011101',
    '\u00e8': '110100', '\u00fb': '110111',
    '\u00ef': '110101', '\u00fc': '010110',
  };

  static const String _numberIndicator = '001111';
  static const String _uppercaseIndicator = '000001';

  static const Map<String, String> _accentMap = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n', 'ÿ': 'y',
    'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A',
    'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
    'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
    'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
    'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
    'Ç': 'C', 'Ñ': 'N', 'Ÿ': 'Y',
  };

  static String stripAccents(String text) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      result.write(_accentMap[char] ?? char);
    }
    return result.toString();
  }

  static String filterText(String text, {required bool ignorarAcentos, required bool caracteresEspeciais}) {
    if (ignorarAcentos) {
      text = stripAccents(text);
    }
    if (!caracteresEspeciais) {
      StringBuffer filtered = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        final char = text[i];
        if (char == ' ' || RegExp(r'[a-zA-Z0-9]').hasMatch(char) || _charToBraille.containsKey(char)) {
          filtered.write(char);
        }
      }
      return filtered.toString();
    }
    return text;
  }

  static String charToBraille(String char) {
    if (_charToBraille.containsKey(char)) {
      return _charToBraille[char]!;
    }
    final lower = char.toLowerCase();
    if (_charToBraille.containsKey(lower)) {
      return _charToBraille[lower]!;
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
