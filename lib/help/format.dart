class FormatHelp {
  String cpfMask(String value) {
    if (value.length != 11) return value;
    return '${value.substring(0, 3)}.${value.substring(3, 6)}.${value.substring(6, 9)}-${value.substring(9, 11)}';
  }
}
