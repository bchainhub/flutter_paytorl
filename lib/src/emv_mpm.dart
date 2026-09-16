/// Raw ASCII EMV MPM envelope inspection, not national-scheme validation.
/// QRIS fixture source: docs.midtrans.com/docs/gopay-qris-pos-integration.
class EmvMpmInspection {
  final Map<String, String> fields;
  final Map<String, Map<String, String>> templates;
  EmvMpmInspection._(
    Map<String, String> fields,
    Map<String, Map<String, String>> templates,
  ) : fields = Map.unmodifiable(fields),
      templates = Map.unmodifiable(
        templates.map(
          (key, value) =>
              MapEntry(key, Map<String, String>.unmodifiable(value)),
        ),
      );
  Map<String, dynamic> toJson() => {'fields': fields, 'templates': templates};
}

Map<String, String> _readTlv(String input) {
  final fields = <String, String>{};
  var offset = 0;
  while (offset < input.length) {
    if (offset + 4 > input.length)
      throw FormatException('Malformed EMV TLV header');
    final header = input.substring(offset, offset + 4);
    if (!RegExp(r'^[0-9]{4}$').hasMatch(header))
      throw FormatException('Malformed EMV TLV header');
    final tag = header.substring(0, 2);
    final length = int.parse(header.substring(2));
    if (length == 0 ||
        offset + 4 + length > input.length ||
        fields.containsKey(tag))
      throw FormatException('Truncated, empty or duplicate EMV TLV field');
    fields[tag] = input.substring(offset + 4, offset + 4 + length);
    offset += 4 + length;
  }
  return fields;
}

String _checksum(String input) {
  var crc = 0xffff;
  for (final byte in input.codeUnits) {
    crc ^= byte << 8;
    for (var bit = 0; bit < 8; bit++) {
      crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xffff;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}

/// Inspects TLV/CRC only. Does not identify QRIS or derive payment destinations.
EmvMpmInspection inspectEmvMpm(String input) {
  if (input.length > 4096 || !RegExp(r'^[\x20-\x7e]+$').hasMatch(input))
    throw FormatException(
      'Unsupported EMV input: expected at most 4096 printable ASCII characters',
    );
  final fields = _readTlv(input);
  if (!input.startsWith('000201') ||
      !RegExp(r'6304[0-9A-F]{4}$').hasMatch(input))
    throw FormatException('Unsupported EMV format or CRC placement');
  if (fields['63'] != _checksum(input.substring(0, input.length - 4)))
    throw FormatException('Invalid EMV CRC');
  final templates = <String, Map<String, String>>{};
  for (final entry in fields.entries) {
    final id = int.parse(entry.key);
    if ((id >= 26 && id <= 51) || id == 62 || id == 64 || id >= 80)
      templates[entry.key] = _readTlv(entry.value);
  }
  return EmvMpmInspection._(fields, templates);
}
