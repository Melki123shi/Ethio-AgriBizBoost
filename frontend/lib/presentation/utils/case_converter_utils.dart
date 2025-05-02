class CaseConverter {
  static String toPascalCase(String input) {
    String output = '';
    bool capitalizeNext = true;

    for (var rune in input.runes) {
      var char = String.fromCharCode(rune);

      if (char == '_') {
        capitalizeNext = true;
      } else {
        output += capitalizeNext ? char.toUpperCase() : char.toLowerCase();
        capitalizeNext = false;
      }
    }

    return output;
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
