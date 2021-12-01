import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_forever/matomo_forever.dart';

void main() {
  const String site_url = String.fromEnvironment("site_url");
  const String token_auth = String.fromEnvironment("token_auth");
  const String idsite = String.fromEnvironment("idsite");
  const String action_name = String.fromEnvironment("action_name");

  test('intialize', () {
    MatomoForever.init(
      site_url,
      int.tryParse(idsite) ?? 0,
      tokenAuth: token_auth,
    );
    expect(MatomoForever.isInitialized, true, reason: "Not initialized");
  });

  test('track', () async {
    expect(await MatomoForever.track(action_name), true,
        reason: "Couldn't track");
  });
}
