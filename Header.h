#import <rootless.h>
#import <dlfcn.h>
#import "../YouTubeHeader/YTInlinePlayerBarContainerView.h"
#import "../YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/QTMIcon.h"
#import "../YouTubeHeader/YTQTMButton.h"
#import "../YouTubeHeader/UIView+YouTube.h"

@interface YTSettingsSectionItemManager (YTVideoOverlay)
- (void)updateYTVideoOverlaySectionWithEntry:(id)entry;
@end

@interface YTMainAppControlsOverlayView (YTVideoOverlay)
- (YTQTMButton *)button:(NSString *)tweakId;
- (UIImage *)buttonImage:(NSString *)tweakId;
- (YTQTMButton *)createButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector;
@end

@interface YTInlinePlayerBarContainerView (YTVideoOverlay)
- (YTQTMButton *)button:(NSString *)tweakId;
- (UIImage *)buttonImage:(NSString *)tweakId;
- (YTQTMButton *)createButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector;
@end

#define _LOC(b, x) [b localizedStringForKey:x value:nil table:nil]
#define LOC(x) _LOC(tweakBundle, x)
