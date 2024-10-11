import 'package:azure_application_insights/src/connection_string.dart';
import 'package:test/test.dart';

void main() {
  _parseFailures();
  _parseSuccesses();

  _ingestionEndpointFailures();
  _ingestionEndpointSuccesses();
}

void _parseFailures() {
  group(
    'Parse failures',
    () {
      test(
        'cannot parse empty string',
        () {
          expect(
            () => parseConnectionString(''),
            throwsA(
              const TypeMatcher<UnsupportedError>().having(
                (e) => e.message,
                'message',
                equals('Connection string cannot be an empty string'),
              ),
            ),
          );
        },
      );

      test(
        'cannot parse invalid key/value pair syntax',
        () {
          void doVerify({
            required String connectionString,
            required String expectedFaultyKeyValuePair,
          }) {
            expect(
              () => parseConnectionString(connectionString),
              throwsA(
                const TypeMatcher<UnsupportedError>().having(
                  (e) => e.message,
                  'message',
                  equals(
                      "Connection string contains portion '$expectedFaultyKeyValuePair', which cannot be parsed. Expected format is key=value"),
                ),
              ),
            );
          }

          doVerify(
            connectionString: 'foo<-bar',
            expectedFaultyKeyValuePair: 'foo<-bar',
          );
          doVerify(
            connectionString: 'a=b;c=d;e;f=g',
            expectedFaultyKeyValuePair: 'e',
          );
        },
      );

      test(
        'cannot parse when there are duplicate keys',
        () {
          void doVerify({
            required String connectionString,
            required String expectedDuplicateKey,
          }) {
            expect(
              () => parseConnectionString(connectionString),
              throwsA(
                const TypeMatcher<UnsupportedError>().having(
                  (e) => e.message,
                  'message',
                  equals(
                      'Connection string contains duplicate key, $expectedDuplicateKey'),
                ),
              ),
            );
          }

          doVerify(
            connectionString: 'a=b;a=c',
            expectedDuplicateKey: 'a',
          );
          doVerify(
            connectionString: 'a=b;c=d;a=d',
            expectedDuplicateKey: 'a',
          );
        },
      );

      test(
        'cannot parse if instrumentation key is missing',
        () {
          void doVerify({required String connectionString}) {
            expect(
              () => parseConnectionString(connectionString),
              throwsA(
                const TypeMatcher<UnsupportedError>().having(
                  (e) => e.message,
                  'message',
                  equals(
                      "Connection string does not contain required entry, 'InstrumentationKey': $connectionString"),
                ),
              ),
            );
          }

          doVerify(
            connectionString: 'a=b',
          );
          doVerify(
            connectionString: 'a=b;c=d;e=f',
          );
        },
      );
    },
  );
}

void _parseSuccesses() {
  group(
    'Parse successes',
    () {
      test(
        'simple, instrumentation key only',
        () {
          void doVerify({
            required String connectionString,
            required String expectedInstrumentationKey,
          }) {
            final result = parseConnectionString(connectionString);
            expect(result.instrumentationKey, expectedInstrumentationKey);
          }

          doVerify(
            connectionString: 'InstrumentationKey=a',
            expectedInstrumentationKey: 'a',
          );
          doVerify(
            connectionString: 'InstrumentationKey=bar',
            expectedInstrumentationKey: 'bar',
          );
          doVerify(
            connectionString: 'InstrumentationKey=bar;',
            expectedInstrumentationKey: 'bar',
          );
          doVerify(
            connectionString: ';InstrumentationKey=bar;',
            expectedInstrumentationKey: 'bar',
          );
          doVerify(
            connectionString: 'InstrumentationKey= b a r ',
            expectedInstrumentationKey: ' b a r ',
          );
        },
      );
      test(
        'complex, more than just instrumentation key',
        () {
          void doVerify({
            required String connectionString,
            required ConnectionString expected,
          }) {
            final result = parseConnectionString(connectionString);
            expect(result, expected);
          }

          doVerify(
            connectionString: 'InstrumentationKey=whatever;a=b;c=d;e=f',
            expected: ConnectionString(
              instrumentationKey: 'whatever',
              ingestionEndpoint: null,
              endpointSuffix: null,
              location: null,
            ),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=whatever;this=isignored;IngestionEndpoint=someexplicitendpoint',
            expected: ConnectionString(
              instrumentationKey: 'whatever',
              ingestionEndpoint: 'someexplicitendpoint',
              endpointSuffix: null,
              location: null,
            ),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=mykey;IngestionEndpoint=some.where;EndpointSuffix=au;Location=brisbane',
            expected: ConnectionString(
              instrumentationKey: 'mykey',
              ingestionEndpoint: 'some.where',
              endpointSuffix: 'au',
              location: 'brisbane',
            ),
          );
        },
      );
    },
  );
}

void _ingestionEndpointFailures() {
  group(
    'Ingestion endpoint failures',
    () {
      test(
        'invalid ingestion endpoint',
        () {
          final parsedConnectionString = parseConnectionString(
              'InstrumentationKey=a;IngestionEndpoint=this cannot work');
          expect(
            () => parsedConnectionString.getIngestionEndpoint(),
            throwsA(
              const TypeMatcher<UnsupportedError>().having(
                (e) => e.message,
                'message',
                equals(
                    'IngestionEndpoint value in connection string is not a valid URI: this cannot work'),
              ),
            ),
          );
        },
      );

      test(
        'invalid location',
        () {
          final parsedConnectionString = parseConnectionString(
              'InstrumentationKey=a;EndpointSuffix=au;Location=nope!');
          expect(
            () => parsedConnectionString.getIngestionEndpoint(),
            throwsA(
              const TypeMatcher<UnsupportedError>().having(
                (e) => e.message,
                'message',
                equals(
                    'Location value in connection string is invalid because it contains characters that are not either letters or digits: nope!'),
              ),
            ),
          );
        },
      );
    },
  );
}

void _ingestionEndpointSuccesses() {
  group(
    'Ingestion endpoint successes',
    () {
      void doVerify({
        required String connectionString,
        required Uri expected,
      }) {
        final parsedConnectionString = parseConnectionString(connectionString);
        final result = parsedConnectionString.getIngestionEndpoint();
        expect(result, expected);
      }

      test(
        'explicit ingestion endpoint in connection string',
        () {
          doVerify(
            connectionString:
                'InstrumentationKey=a;IngestionEndpoint=https://somewhere.com/whatever',
            expected: Uri.parse('https://somewhere.com/whatever'),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=a;IngestionEndpoint=https://australiaeast-1.in.applicationinsights.azure.com/',
            expected: Uri.parse(
                'https://australiaeast-1.in.applicationinsights.azure.com/'),
          );
        },
      );

      test(
        'endpoint suffix without location',
        () {
          doVerify(
            connectionString: 'InstrumentationKey=a;EndpointSuffix=au',
            expected: Uri.parse('https://dc.au'),
          );
          doVerify(
            connectionString: 'InstrumentationKey=a;EndpointSuffix=.au',
            expected: Uri.parse('https://dc.au'),
          );
          doVerify(
            connectionString: 'InstrumentationKey=a;EndpointSuffix=....foo',
            expected: Uri.parse('https://dc.foo'),
          );
          doVerify(
            connectionString: 'InstrumentationKey=a;EndpointSuffix=  ....foo  ',
            expected: Uri.parse('https://dc.foo'),
          );
        },
      );

      test(
        'endpoint suffix with location',
        () {
          doVerify(
            connectionString:
                'InstrumentationKey=a;EndpointSuffix=au;Location=brisbane',
            expected: Uri.parse('https://brisbane.dc.au'),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=a;EndpointSuffix=au;Location=brisbane.',
            expected: Uri.parse('https://brisbane.dc.au'),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=a;EndpointSuffix=au;Location=brisbane...',
            expected: Uri.parse('https://brisbane.dc.au'),
          );
          doVerify(
            connectionString:
                'InstrumentationKey=a;EndpointSuffix=au;Location=  adelaide...  ',
            expected: Uri.parse('https://adelaide.dc.au'),
          );
        },
      );

      test(
        'fallback to default endpoint',
        () {
          doVerify(
            connectionString: 'InstrumentationKey=a',
            expected: Uri.parse('https://dc.services.visualstudio.com/'),
          );
        },
      );
    },
  );
}
