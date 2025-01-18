#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#if TARGET_OS_SIMULATOR
#import <PSHeader/Misc.h>
#else
#import <rootless.h>
#endif

#define AccessibilityLabelKey @"accessibilityLabel"
#define ToggleKey @"toggle"
#define AsTextKey @"asText"
#define SelectorKey @"selector"
#define UpdateImageOnVisibleKey @"updateImageOnVisible"

@interface YTSettingsSectionItemManager (YTVideoOverlayInit)
+ (void)registerTweak:(NSString *)tweakId metadata:(NSDictionary *)metadata;
@end
