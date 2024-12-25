#import <YouTubeHeader/YTSettingsSectionItemManager.h>

#define AccessibilityLabelKey @"accessibilityLabel"
#define ToggleKey @"toggle"
#define AsTextKey @"asText"
#define SelectorKey @"selector"
#define UpdateImageOnVisibleKey @"updateImageOnVisible"

@interface YTSettingsSectionItemManager (YTVideoOverlayInit)
+ (void)registerTweak:(NSString *)tweakId metadata:(NSDictionary *)metadata;
@end
