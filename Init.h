#import <YouTubeHeader/YTSettingsSectionItemManager.h>

@interface YTSettingsSectionItemManager (YTVideoOverlayInit)
+ (void)registerTweak:(NSString *)tweakId;
+ (void)setTweak:(NSString *)tweakId withEnabledKey:(NSString *)enabledKey;
@end
