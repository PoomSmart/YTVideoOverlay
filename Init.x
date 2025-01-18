#import <dlfcn.h>
#import "Init.h"

static void initYTVideoOverlay(NSString *tweakKey, NSDictionary *metadata) {
    dlopen([[NSString stringWithFormat:@"%@/Frameworks/YTVideoOverlay.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_LAZY);
#if TARGET_OS_SIMULATOR
    dlopen(realPath2(@"/Library/MobileSubstrate/DynamicLibraries/YTVideoOverlay.dylib"), RTLD_LAZY);
#else
    dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/YTVideoOverlay.dylib"), RTLD_LAZY);
#endif
    [NSClassFromString(@"YTSettingsSectionItemManager") registerTweak:tweakKey metadata:metadata];
}
