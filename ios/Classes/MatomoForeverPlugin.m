#import "MatomoForeverPlugin.h"
#if __has_include(<matomo_forever/matomo_forever-Swift.h>)
#import <matomo_forever/matomo_forever-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "matomo_forever-Swift.h"
#endif

@implementation MatomoForeverPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMatomoForeverPlugin registerWithRegistrar:registrar];
}
@end
