#import <rootless.h>
#import <dlfcn.h>
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"

@interface YTSettingsSectionItemManager (YTVideoOverlayInit)
+ (void)registerTweak:(NSString *)tweakId;
@end

static void initYTVideoOverlay(NSString *TweakKey) {
    dlopen([[NSString stringWithFormat:@"%@/Frameworks/YTVideoOverlay.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_LAZY);
    dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/YTVideoOverlay.dylib"), RTLD_LAZY);
    [NSClassFromString(@"YTSettingsSectionItemManager") registerTweak:TweakKey];
}
