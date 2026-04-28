class SignAssetsMapper {
  static const Map<String, String> handSignsMap = {
    'A': 'assets/signlanguage/A.jpg',
    'B': 'assets/signlanguage/B.jpg',
    'C': 'assets/signlanguage/C.jpg',
    'D': 'assets/signlanguage/D.jpg',
    'E': 'assets/signlanguage/E.jpg',
    'F': 'assets/signlanguage/F.jpg',
    'G': 'assets/signlanguage/G.jpg',
    'H': 'assets/signlanguage/H.jpg',
    'I': 'assets/signlanguage/I.jpg',
    'J': 'assets/signlanguage/J.jpg',
    'K': 'assets/signlanguage/K.jpg',
    'L': 'assets/signlanguage/L.jpg',
    'M': 'assets/signlanguage/M.jpg',
    'N': 'assets/signlanguage/N.jpg',
    'O': 'assets/signlanguage/O.jpg',
    'P': 'assets/signlanguage/P.jpg',
    'Q': 'assets/signlanguage/Q.jpg',
    'R': 'assets/signlanguage/R.jpg',
    'S': 'assets/signlanguage/S.jpg',
    'T': 'assets/signlanguage/T.jpg',
    'U': 'assets/signlanguage/U.jpg',
    'V': 'assets/signlanguage/V.jpg',
    'W': 'assets/signlanguage/W.jpg',
    'X': 'assets/signlanguage/X.jpg',
    'Y': 'assets/signlanguage/Y.jpg',
    'Z': 'assets/signlanguage/Z.jpg',
    ' ': 'assets/signlanguage/space.jpg',
    '0': 'assets/signlanguage/0.jpg',
    '1': 'assets/signlanguage/1.jpg',
    '2': 'assets/signlanguage/2.jpg',
    '3': 'assets/signlanguage/3.jpg',
    '4': 'assets/signlanguage/4.jpg',
    '5': 'assets/signlanguage/5.jpg',
    '6': 'assets/signlanguage/6.jpg',
    '7': 'assets/signlanguage/7.jpg',
    '8': 'assets/signlanguage/8.jpg',
    '9': 'assets/signlanguage/9.jpg',
  };

  static List<String> toAssets(String input) {
    final output = <String>[];
    for (final char in input.toUpperCase().split('')) {
      final asset = handSignsMap[char];
      if (asset != null) output.add(asset);
    }
    return output;
  }

  static List<String> supportedCharacters(String input) {
    final output = <String>[];
    for (final char in input.toUpperCase().split('')) {
      if (handSignsMap.containsKey(char)) output.add(char);
    }
    return output;
  }
}
