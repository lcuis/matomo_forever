import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_forever/matomo_forever.dart';

void main() {
  const String siteUrl = String.fromEnvironment("site_url");
  const String tokenAuth = String.fromEnvironment("token_auth");
  const String idsite = String.fromEnvironment("idsite");
  const String actionName = String.fromEnvironment("action_name");
  test('intialize', () {
    MatomoForever.init(
      siteUrl,
      int.tryParse(idsite) ?? 0,
      tokenAuth: tokenAuth,
    );
    expect(MatomoForever.isInitialized, true, reason: "Not initialized");
  });

  test('track', () async {
    expect(await MatomoForever.track(actionName), true,
        reason: "Couldn't track");
  });
}
