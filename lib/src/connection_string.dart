/// Represents a parsed connection string, exposing only the information we actually care about.
class ConnectionString {
  ConnectionString({
    required this.instrumentationKey,
    required this.ingestionEndpoint,
    required this.endpointSuffix,
    required this.location,
  });

  final String instrumentationKey;
  final String? ingestionEndpoint;
  final String? endpointSuffix;
  final String? location;

  @override
  bool operator ==(Object other) =>
      other is ConnectionString &&
      instrumentationKey == other.instrumentationKey &&
      ingestionEndpoint == other.ingestionEndpoint &&
      endpointSuffix == other.endpointSuffix &&
      location == other.location;

  @override
  int get hashCode => Object.hash(
        instrumentationKey,
        ingestionEndpoint,
        endpointSuffix,
        location,
      );
}

/// Parse [connectionString] into a [ConnectionString], throwing if it is invalid.
///
/// See https://learn.microsoft.com/en-us/azure/azure-monitor/app/sdk-connection-string?tabs=dotnet5#syntax
ConnectionString parseConnectionString(String connectionString) {
  String getRequiredEntry(Map<String, String> entries, String entryKey) {
    final maybeValue = entries[entryKey];

    if (maybeValue == null) {
      throw UnsupportedError(
          "Connection string does not contain required entry, '$entryKey': $connectionString");
    }

    return maybeValue;
  }

  if (connectionString.isEmpty) {
    throw UnsupportedError('Connection string cannot be an empty string');
  }

  final seenKeys = <String>{};

  final mapEntries = connectionString
      .split(';')
      .where((s) => s.isNotEmpty)
      .map((potentialKeyValuePair) {
    final keyValuePair = potentialKeyValuePair.split('=');

    if (keyValuePair.length != 2) {
      throw UnsupportedError(
          "Connection string contains portion '$potentialKeyValuePair', which cannot be parsed. Expected format is key=value");
    }

    final key = keyValuePair[0];

    if (seenKeys.contains(key)) {
      throw UnsupportedError('Connection string contains duplicate key, $key');
    }

    seenKeys.add(key);

    final value = keyValuePair[1];
    return MapEntry(key, value);
  });

  final map = Map.fromEntries(mapEntries);
  final instrumentationKey = getRequiredEntry(map, 'InstrumentationKey');

  return ConnectionString(
    instrumentationKey: instrumentationKey,
    ingestionEndpoint: map['IngestionEndpoint'],
    endpointSuffix: map['EndpointSuffix'],
    location: map['Location'],
  );
}

extension ParsedConnectionStringExtensions on ConnectionString {
  /// Get the URI to which telemetry events should be sent for ingestion into App Insights, given the connection string.
  ///
  /// Based on logic in .NET SDK: Microsoft.ApplicationInsights.Extensibility.Implementation.Endpoints.EndpointProvider.GetEndpoint
  Uri getIngestionEndpoint() {
    String? processAndValidateLocation(String? location) {
      if (location == null) {
        return null;
      }

      final trimmedLocation = location.trim().trimEnd('.');

      if (!trimmedLocation.everyCodeUnit(
          (codeUnit) => codeUnit.isDigit() || codeUnit.isLetter())) {
        throw UnsupportedError(
            'Location value in connection string is invalid because it contains characters that are not either letters or digits: $location');
      }

      return '$trimmedLocation.';
    }

    // 1. Check for explicit ingestion endpoint in connection string
    final localIngestionEndpoint = ingestionEndpoint;

    if (localIngestionEndpoint != null) {
      final uri = Uri.tryParse(localIngestionEndpoint);

      if (uri == null || !uri.isAbsolute) {
        throw UnsupportedError(
            'IngestionEndpoint value in connection string is not a valid URI: $localIngestionEndpoint');
      }

      return uri;
    }

    // 2. Check for endpoint suffix with optional location
    final localEndpointSuffix = endpointSuffix;

    if (localEndpointSuffix != null) {
      final endpointSuffix = localEndpointSuffix.trim().trimStart('.');
      const endpointPrefix = 'dc';
      final processedAndValidatedLocation =
          processAndValidateLocation(location);

      final host =
          '${processedAndValidatedLocation ?? ''}$endpointPrefix.$endpointSuffix';
      return Uri(
        scheme: "https",
        host: host,
      );
    }

    // 3. Use default (classic) endpoint
    return Uri.parse('https://dc.services.visualstudio.com/');
  }
}

extension _StringExtensions on String {
  String trimStart(String charactersToRemove) {
    final String escapedChars = RegExp.escape(charactersToRemove);
    final RegExp regex = RegExp('^[$escapedChars]+');
    final String newStr = replaceAll(regex, '').trim();
    return newStr;
  }

  String trimEnd(String charactersToRemove) {
    final String escapedChars = RegExp.escape(charactersToRemove);
    final RegExp regex = RegExp('[$escapedChars]+\$');
    final String newStr = replaceAll(regex, '').trim();
    return newStr;
  }

  bool everyCodeUnit(bool Function(int ch) test) => codeUnits.every(test);
}

extension _CodeUnitExtensions on int {
  bool isDigit() => (this ^ 0x30) <= 9;

  bool isLetter() =>
      // Only checking Latin characters here - presumably that will suffice for our purposes.
      (this >= 65 && this <= 90) || (this >= 97 && this <= 122);
}
