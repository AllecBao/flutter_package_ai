#import "PttAiPackagePlugin.h"
#if __has_include(<ptt_ai_package/ptt_ai_package-Swift.h>)
#import <ptt_ai_package/ptt_ai_package-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ptt_ai_package-Swift.h"
#endif

@implementation PttAiPackagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPttAiPackagePlugin registerWithRegistrar:registrar];
}
@end
