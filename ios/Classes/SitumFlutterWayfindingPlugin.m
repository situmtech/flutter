#import "SitumFlutterWayfindingPlugin.h"
#if __has_include(<situm_flutter/situm_flutter-Swift.h>)
#import <situm_flutter/situm_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
// #import "situm_flutter-Swift.h"
#endif

#import "SITFSDKPlugin.h"

@implementation SitumFlutterWayfindingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SITFSDKPlugin registerWithRegistrar:registrar];
}
@end
