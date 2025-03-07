import 'dart:core';

import 'constants/regex_patterns.dart';
import 'exceptions/payto_exception.dart';
import 'models/payto_json.dart';

/// A class for handling Payto Resource Locators (PRLs)
class Payto {
  /// Internal Uri object
  Uri _uri;

  /// Creates a new Payto instance from a payto URL string
  Payto(String paytoString) : _uri = Uri.parse(paytoString) {
    if (_uri.scheme != 'payto') {
      throw PaytoException('Invalid protocol, must be payto:');
    }
  }

  /// Extracts parts from combined hostname and pathname
  String? _getHostpathParts({String? type, int position = 1}) {
    final hostnamePlusPath = '${_uri.host}${_uri.path}';
    final array = hostnamePlusPath.split('/');
    if (type == null || array[0].toLowerCase() == type) {
      return array.length > position ? array[position] : null;
    }
    return null;
  }

  /// Extracts parts from pathname
  String? _getPathParts([int position = 1]) {
    final array = _uri.path.split('/');
    return array.length > position ? array[position] : null;
  }

  /// Updates parts in pathname
  void _setPathParts(String? value, [int position = 1]) {
    final addressArray = _uri.path.split('/');
    if (value != null) {
      while (addressArray.length <= position) {
        addressArray.add('');
      }
      addressArray[position] = value;
    } else {
      if (addressArray.length > position) {
        addressArray.removeAt(position);
      }
    }
    final newPath = addressArray.where((part) => part.isNotEmpty).join('/');
    _uri = _uri.replace(path: '/$newPath');
  }

  /// Gets email alias for UPI/PIX payments
  String? get accountAlias {
    if (_uri.host == 'upi' || _uri.host == 'pix') {
      final alias = _getPathParts();
      if (alias != null && RegexPatterns.emailRegex.hasMatch(alias)) {
        return alias.toLowerCase();
      }
    }
    return null;
  }

  /// Sets email alias for UPI/PIX payments
  set accountAlias(String? value) {
    if (value != null) {
      if (!RegexPatterns.emailRegex.hasMatch(value)) {
        throw PaytoException('Invalid email address format');
      }
      _setPathParts(value.toLowerCase());
    } else {
      _setPathParts(null);
    }
  }

  /// Gets account number for ACH payments
  int? get accountNumber {
    if (_uri.host == 'ach') {
      final parts = _uri.path.split('/');
      final accountStr = parts.length > 2 ? parts[2] : parts[1];
      if (RegexPatterns.accountNumberRegex.hasMatch(accountStr)) {
        return int.parse(accountStr);
      }
    }
    return null;
  }

  /// Sets account number for ACH payments
  set accountNumber(int? value) {
    if (_uri.host.isEmpty || _uri.host != 'ach') {
      throw PaytoException('Invalid hostname, must be ach');
    }

    if (value != null) {
      final accountStr = value.toString();
      if (!RegexPatterns.accountNumberRegex.hasMatch(accountStr)) {
        throw PaytoException('Invalid account number format');
      }
    }

    final parts = _uri.path.split('/');
    if (parts.length > 2) {
      if (value == null) {
        _setPathParts(null, 2);
        _setPathParts(null, 1);
      } else {
        _setPathParts(value.toString(), 2);
      }
    } else if (parts.length > 1) {
      _setPathParts(value?.toString(), 1);
    }
  }

  /// Gets payment address
  String? get address => _getPathParts();

  /// Sets payment address
  set address(String? value) => _setPathParts(value);

  /// Gets payment amount
  String? get amount => _uri.queryParameters['amount'];

  /// Sets payment amount
  set amount(String? value) {
    if (value != null) {
      _uri = Uri(
        scheme: _uri.scheme,
        host: _uri.host,
        path: _uri.path,
        queryParameters: {..._uri.queryParameters, 'amount': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('amount');
      _uri = Uri(
        scheme: _uri.scheme,
        host: _uri.host,
        path: _uri.path,
        queryParameters: newParams,
      );
    }
  }

  /// Gets asset type from currency
  String? get asset {
    final amountValue = _uri.queryParameters['amount'];
    if (amountValue != null) {
      final amountArray = amountValue.split(':');
      if (amountArray.length > 1 && !isNumeric(amountArray[0])) {
        return amountArray[0];
      }
    }
    return null;
  }

  /// Sets asset type in currency
  set asset(String? value) {
    if (value == null) {
      currency = [null];
    } else {
      currency = [value];
    }
  }

  /// Gets barcode format
  String? get barcode => _uri.queryParameters['barcode']?.toLowerCase();

  /// Sets barcode format
  set barcode(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'barcode': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('barcode');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets BIC/SWIFT code from BIC or IBAN path
  String? get bic {
    if (_uri.host == 'bic') {
      final bicValue = _getHostpathParts(type: 'bic', position: 1);
      return bicValue?.toUpperCase();
    } else if (_uri.host == 'iban') {
      if (_uri.path.length > 2) {
        final bicValue = _getHostpathParts(type: 'iban', position: 1);
        return bicValue?.toUpperCase();
      }
    }
    return null;
  }

  /// Sets BIC/SWIFT code
  set bic(String? value) {
    if (value != null && !RegexPatterns.bicRegex.hasMatch(value)) {
      throw PaytoException('Invalid BIC format');
    }
    if (_uri.host == 'bic') {
      _setPathParts(value?.toUpperCase(), 1);
    } else if (_uri.host == 'iban') {
      if (_uri.path.length > 2) {
        _setPathParts(value?.toUpperCase(), 1);
      } else if (_uri.path.length > 1) {
        final ibanStr = _getHostpathParts(type: 'iban', position: 1);
        if (ibanStr != null) {
          _setPathParts(ibanStr, 2);
          _setPathParts(value?.toUpperCase(), 1);
        } else {
          _setPathParts(value?.toUpperCase(), 1);
        }
      }
    }
  }

  /// Gets currency as [asset, fiat] tuple
  List<String?> get currency {
    final result = <String?>[null, null];
    final amountValue = _uri.queryParameters['amount'];
    final fiatValue = _uri.queryParameters['fiat'];

    if (amountValue != null) {
      final amountArray = amountValue.split(':');
      if (amountArray.length > 1) {
        result[0] = amountArray[0];
      }
    }

    if (fiatValue != null) {
      result[1] = fiatValue;
    }

    return result;
  }

  /// Sets currency from [token, fiat, value] array
  set currency(List<String?> valueArray) {
    if (valueArray.length > 3) {
      throw PaytoException('Invalid currency array length');
    }

    final token = valueArray[0];
    final fiat = valueArray.length > 1 ? valueArray[1] : null;
    final value = valueArray.length > 2 ? valueArray[2] : null;

    final amountValue = _uri.queryParameters['amount'];
    String? prevToken, prevValue;

    if (amountValue != null) {
      final amountArray = amountValue.split(':');
      if (amountArray.length > 1) {
        prevToken = amountArray[0];
        prevValue = amountArray[1];
      } else {
        prevValue = amountArray[0];
      }
    }

    if (fiat != null) {
      this.fiat = fiat.toLowerCase();
    } else if (fiat == null) {
      this.fiat = null;
    }

    if (token != null) {
      amount = '$token:${value ?? prevValue ?? ''}';
    } else if (token == null) {
      amount =
          value != null || prevValue != null ? ':${value ?? prevValue}' : null;
    } else if (value != null) {
      amount = '${prevToken != null ? '$prevToken:' : ''}$value';
    }
  }

  /// Gets payment deadline as Unix timestamp
  int? get deadline {
    final dl = _uri.queryParameters['dl'];
    if (dl != null && RegexPatterns.unixTimestampRegex.hasMatch(dl)) {
      final timestamp = int.parse(dl);
      return timestamp >= 0 ? timestamp : null;
    }
    return null;
  }

  /// Sets payment deadline as Unix timestamp
  set deadline(int? value) {
    if (value != null) {
      if (value < 0 ||
          !RegexPatterns.unixTimestampRegex.hasMatch(value.toString())) {
        throw PaytoException(
            'Invalid deadline format. Must be a positive integer (Unix timestamp).');
      }
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'dl': value.toString()},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('dl');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets donation flag
  bool? get donate {
    if (_uri.queryParameters.containsKey('donate')) {
      final donateValue = _uri.queryParameters['donate'];
      return donateValue != null
          ? (donateValue == '1' ? true : (donateValue == '0' ? false : null))
          : null;
    }
    return null;
  }

  /// Sets donation flag
  set donate(bool? value) {
    if (value == true) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'donate': '1'},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('donate');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets fiat currency code
  String? get fiat => _uri.queryParameters['fiat']?.toLowerCase();

  /// Sets fiat currency code
  set fiat(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'fiat': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('fiat');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets URL fragment
  String get fragment => _uri.fragment;

  /// Sets URL fragment
  set fragment(String value) {
    _uri = _uri.replace(fragment: value);
  }

  /// Gets complete host (hostname:port)
  String get host => _uri.host;

  /// Gets hostname without port
  String get hostname => _uri.host.toLowerCase();

  /// Gets complete URL string
  String get href => _uri.toString();

  /// Gets IBAN from path
  String? get iban {
    if (_uri.host == 'iban') {
      final parts = _uri.path.split('/');
      final ibanStr = parts.length > 2 ? parts[2] : parts[1];
      return RegexPatterns.ibanRegex.hasMatch(ibanStr)
          ? ibanStr.toUpperCase()
          : null;
    }
    return null;
  }

  /// Sets IBAN in path
  set iban(String? value) {
    if (value != null && !RegexPatterns.ibanRegex.hasMatch(value)) {
      throw PaytoException('Invalid IBAN format');
    }
    if (_uri.host == 'iban') {
      final parts = _uri.path.split('/');
      if (parts.length > 2) {
        if (value == null) {
          _setPathParts(null, 2);
          _setPathParts(null, 1);
        } else {
          _setPathParts(value.toUpperCase(), 2);
        }
      } else if (parts.length > 1) {
        _setPathParts(value?.toUpperCase(), 1);
      }
    }
  }

  /// Gets item description
  String? get item {
    final itemValue = _uri.queryParameters['item'];
    return itemValue != null && itemValue.length <= 40 ? itemValue : null;
  }

  /// Sets item description
  set item(String? value) {
    if (value != null && value.length <= 40) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'item': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('item');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets location based on void type
  String? get location {
    final voidType = this.void_;
    if (voidType == null) return null;

    final value = _uri.queryParameters['loc'];
    if (value == null) return null;

    if (voidType == 'geo') {
      return RegexPatterns.geoLocationRegex.hasMatch(value) ? value : null;
    }
    if (voidType == 'plus') {
      return RegexPatterns.plusCodeRegex.hasMatch(value) ? value : null;
    }

    return value;
  }

  /// Sets location value
  set location(String? value) {
    if (value == null) {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('loc');
      _uri = _uri.replace(queryParameters: newParams);
      return;
    }

    final voidType = this.void_;
    if (voidType == null) {
      throw PaytoException('Void type must be set before setting location');
    }

    if (voidType == 'geo') {
      if (!RegexPatterns.geoLocationRegex.hasMatch(value)) {
        throw PaytoException(
            'Invalid geo location format. Must be "latitude,longitude" with valid coordinates.');
      }
    } else if (voidType == 'plus') {
      if (!RegexPatterns.plusCodeRegex.hasMatch(value)) {
        throw PaytoException('Invalid plus code format.');
      }
    }

    _uri = _uri.replace(
      queryParameters: {..._uri.queryParameters, 'loc': value},
    );
  }

  /// Gets payment message
  String? get message => _uri.queryParameters['message'];

  /// Sets payment message
  set message(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'message': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('message');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets payment network
  String get network => _uri.host.toLowerCase();

  /// Gets organization name
  String? get organization => _uri.queryParameters['org'];

  /// Sets organization name
  set organization(String? value) {
    if (value != null && value.length <= 25) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'org': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('org');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets URL origin
  String get origin => 'payto://${_uri.host}';

  /// Gets URL path
  String get path => _uri.path;

  /// Gets URL port
  String? get port => _uri.port.toString();

  /// Gets URL protocol
  String get protocol => '${_uri.scheme}:';

  /// Gets receiver name
  String? get receiverName => _uri.queryParameters['receiver-name'];

  /// Sets receiver name
  set receiverName(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'receiver-name': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('receiver-name');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets recurring payment info
  String? get recurring => _uri.queryParameters['rc']?.toLowerCase();

  /// Sets recurring payment info
  set recurring(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'rc': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('rc');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets routing number for ACH payments
  int? get routingNumber {
    if (_uri.host == 'ach') {
      if (_uri.path.length > 2) {
        final routingNumberStr = _getHostpathParts(type: 'ach', position: 1);
        return routingNumberStr != null &&
                RegexPatterns.routingNumberRegex.hasMatch(routingNumberStr)
            ? int.parse(routingNumberStr)
            : null;
      }
    }
    return null;
  }

  /// Sets routing number for ACH payments
  set routingNumber(int? value) {
    if (value != null &&
        !RegexPatterns.routingNumberRegex.hasMatch(value.toString())) {
      throw PaytoException(
          'Invalid routing number format. Must be exactly 9 digits.');
    }
    if (_uri.path.length > 2) {
      _setPathParts(value?.toString(), 1);
    } else if (_uri.path.length > 1) {
      final accountNumberStr = _getHostpathParts(type: 'ach', position: 1);
      if (accountNumberStr != null) {
        _setPathParts(accountNumberStr, 2);
        _setPathParts(value?.toString(), 1);
      } else {
        _setPathParts(value?.toString(), 1);
      }
    }
  }

  /// Gets RTL (right-to-left) flag
  bool? get rtl {
    if (_uri.queryParameters.containsKey('rtl')) {
      final rtlValue = _uri.queryParameters['rtl'];
      return rtlValue != null
          ? (rtlValue == '1' ? true : (rtlValue == '0' ? false : null))
          : null;
    }
    return null;
  }

  /// Sets RTL (right-to-left) flag
  set rtl(bool? value) {
    if (value == true) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'rtl': '1'},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('rtl');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets URL search string
  String get search => _uri.query.isEmpty ? '' : '?${_uri.query}';

  /// Gets payment split information
  List<dynamic>? get split {
    final splitValue = _uri.queryParameters['split'];
    if (splitValue != null) {
      final parts = splitValue.split('@');
      if (parts.length == 2) {
        final amountPart = parts[0];
        final receiver = parts[1];
        final isPercentage = amountPart.startsWith('p:');
        final amount = isPercentage ? amountPart.substring(2) : amountPart;
        return [receiver, amount, isPercentage];
      }
    }
    return null;
  }

  /// Sets payment split information
  set split(List<dynamic>? value) {
    if (value == null) {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('split');
      _uri = _uri.replace(queryParameters: newParams);
      return;
    }

    if (value.length != 3) {
      throw PaytoException(
          'Split requires receiver, amount, and percentage flag');
    }

    final receiver = value[0] as String;
    final amount = value[1] as String;
    final isPercentage = value[2] as bool;

    if (receiver.isEmpty || amount.isEmpty) {
      throw PaytoException('Split requires both receiver and amount');
    }

    final prefix = isPercentage ? 'p:' : '';
    _uri = _uri.replace(
      queryParameters: {
        ..._uri.queryParameters,
        'split': '$prefix$amount@$receiver'
      },
    );
  }

  /// Gets swap type
  String? get swap => _uri.queryParameters['swap']?.toLowerCase();

  /// Sets swap type
  set swap(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'swap': value.toLowerCase()},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('swap');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets payment value from amount
  double? get value {
    final amountStr = _uri.queryParameters['amount'];
    if (amountStr != null) {
      final parts = amountStr.split(':');
      final valueStr = parts.length > 1 ? parts[1] : parts[0];
      try {
        return double.parse(valueStr);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Sets payment value in amount
  set value(double? value) {
    if (value == null) return;

    final currentAmount = _uri.queryParameters['amount'];
    if (currentAmount != null) {
      final parts = currentAmount.split(':');
      if (parts.length > 1) {
        _uri = _uri.replace(
          queryParameters: {
            ..._uri.queryParameters,
            'amount': '${parts[0]}:$value'
          },
        );
      } else {
        _uri = _uri.replace(
          queryParameters: {
            ..._uri.queryParameters,
            'amount': value.toString()
          },
        );
      }
    } else {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'amount': value.toString()},
      );
    }
  }

  /// Gets void type
  String? get void_ {
    if (_uri.host == 'void' && _uri.path.length > 1) {
      final parts = _uri.path.split('/');
      return parts[1].toLowerCase();
    }
    return null;
  }

  /// Sets void type
  set void_(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        host: 'void',
        path: '/${value.toLowerCase()}',
      );
    } else {
      if (_uri.host == 'void') {
        _uri = _uri.replace(path: '/');
      }
    }
  }

  /// Helper method to check if a string is numeric
  bool isNumeric(String str) {
    try {
      double.parse(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Converts to URI string
  @override
  String toString() => _uri.toString();

  /// Converts to JSON string
  String toJson() => _uri.toString();

  /// Converts to PaytoJSON object with all properties
  PaytoJson toJsonObject() => PaytoJson(
        accountAlias: accountAlias,
        accountNumber: accountNumber,
        address: address,
        amount: amount,
        asset: asset,
        barcode: barcode,
        bic: bic,
        colorBackground: _uri.queryParameters['color-b'],
        colorForeground: _uri.queryParameters['color-f'],
        currency: currency,
        deadline: deadline,
        donate: donate,
        fiat: fiat,
        fragment: fragment,
        host: host,
        hostname: hostname,
        href: href,
        iban: iban,
        item: item,
        location: location,
        message: message,
        network: network,
        organization: organization,
        origin: origin,
        path: path,
        port: port,
        protocol: protocol,
        receiverName: receiverName,
        recurring: recurring,
        routingNumber: routingNumber,
        rtl: rtl,
        search: search,
        split: split,
        swap: swap,
        value: value,
        void_: void_,
      );

  /// Gets background color
  String? get colorBackground => _uri.queryParameters['color-b'];

  /// Sets background color
  set colorBackground(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'color-b': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('color-b');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }

  /// Gets foreground color
  String? get colorForeground => _uri.queryParameters['color-f'];

  /// Sets foreground color
  set colorForeground(String? value) {
    if (value != null) {
      _uri = _uri.replace(
        queryParameters: {..._uri.queryParameters, 'color-f': value},
      );
    } else {
      final newParams = Map<String, String>.from(_uri.queryParameters)
        ..remove('color-f');
      _uri = _uri.replace(queryParameters: newParams);
    }
  }
}
