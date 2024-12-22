#import <YouTubeHeader/MLFormat.h>
#import <YouTubeHeader/QTMIcon.h>
#import <YouTubeHeader/UIView+YouTube.h>
#import <YouTubeHeader/YTColor.h>
#import <YouTubeHeader/YTCommonUtils.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/YTQTMButton.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSingleVideoController.h>
#import <YouTubeHeader/YTTypeStyle.h>
#import "Header.h"
#import "Init.h"

static const NSInteger YTVideoOverlaySection = 1222;

NSMutableArray <NSString *> *tweaks;
NSMutableArray <NSString *> *tweaksWithOwnToggle;
NSMutableArray <NSString *> *topButtons;
NSMutableArray <NSString *> *bottomButtons;

static NSBundle *TweakBundle(NSString *name) {
    NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
    return tweakBundlePath
        ? [NSBundle bundleWithPath:tweakBundlePath]
        : [NSBundle bundleWithPath:[NSString stringWithFormat:ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), name]];
}

static NSString *EnabledKey(NSString *name) {
    return [NSString stringWithFormat:@"YTVideoOverlay-%@-Enabled", name];
}

static BOOL TweakEnabled(NSString *name) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey(name)];
}

static NSString *PositionKey(NSString *name) {
    return [NSString stringWithFormat:@"YTVideoOverlay-%@-Position", name];
}

static int ButtonPosition(NSString *name) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:PositionKey(name)];
}

static BOOL UseTopButton(NSString *name) {
    return TweakEnabled(name) && ButtonPosition(name) == 0;
}

static BOOL UseBottomButton(NSString *name) {
    return TweakEnabled(name) && ButtonPosition(name) == 1;
}

static NSMutableArray *topControls(YTMainAppControlsOverlayView *self, NSMutableArray *controls) {
    for (NSString *name in topButtons) {
        if (UseTopButton(name))
            [controls insertObject:[self button:name] atIndex:0];
    }
    return controls;
}

static void setDefaultTextStyle(YTQTMButton *button) {
    [button setTitleColor:[%c(YTColor) white1] forState:0];
    YTDefaultTypeStyle *defaultTypeStyle = [%c(YTTypeStyle) defaultTypeStyle];
    UIFont *font = [defaultTypeStyle respondsToSelector:@selector(ytSansFontOfSize:weight:)]
        ? [defaultTypeStyle ytSansFontOfSize:10 weight:UIFontWeightSemibold]
        : [defaultTypeStyle fontOfSize:10 weight:UIFontWeightSemibold];
    button.titleLabel.font = font;
    button.titleLabel.numberOfLines = 3;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
}

static YTQTMButton *createButtonTop(BOOL isText, YTMainAppControlsOverlayView *self, NSString *buttonId, NSString *accessibilityLabel, SEL selector) {
    if (!self) return nil;
    CGFloat padding = [[self class] topButtonAdditionalPadding];
    YTQTMButton *button;
    if (isText) {
        button = [%c(YTQTMButton) textButton];
        button.accessibilityLabel = accessibilityLabel;
        button.verticalContentPadding = padding;
        [button setTitle:@"Auto" forState:0];
        [button sizeToFit];
        setDefaultTextStyle(button);
    } else {
        UIImage *image = [self buttonImage:buttonId];
        button = [self buttonWithImage:image accessibilityLabel:accessibilityLabel verticalContentPadding:padding];
    }
    button.hidden = YES;
    button.alpha = 0;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    if (![topButtons containsObject:buttonId])
        [topButtons addObject:buttonId];
    @try {
        [[self valueForKey:@"_topControlsAccessibilityContainerView"] addSubview:button];
    } @catch (id ex) {
        [self addSubview:button];
    }
    return button;
}

static YTQTMButton *createButtonBottom(BOOL isText, YTInlinePlayerBarContainerView *self, NSString *buttonId, NSString *accessibilityLabel, SEL selector) {
    if (!self) return nil;
    YTQTMButton *button;
    if (isText) {
        button = [%c(YTQTMButton) textButton];
        button.accessibilityLabel = accessibilityLabel;
        setDefaultTextStyle(button);
    } else {
        UIImage *image = [self buttonImage:buttonId];
        button = [%c(YTQTMButton) iconButton];
        [button setImage:image forState:0];
        [button sizeToFit];
    }
    button.hidden = YES;
    button.exclusiveTouch = YES;
    button.alpha = 0;
    button.minHitTargetSize = 60;
    button.accessibilityLabel = accessibilityLabel;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    if (![bottomButtons containsObject:buttonId])
        [bottomButtons addObject:buttonId];
    [self addSubview:button];
    return button;
}

%group Top

%hook YTMainAppVideoPlayerOverlayViewController

- (void)updateTopRightButtonAvailability {
    %orig;
    YTMainAppVideoPlayerOverlayView *v = [self videoPlayerOverlayView];
    YTMainAppControlsOverlayView *c = [v valueForKey:@"_controlsOverlayView"];
    for (NSString *name in topButtons)
        [c button:name].hidden = !UseTopButton(name);
    [c setNeedsLayout];
}

%end

%hook YTMainAppControlsOverlayView

%new(@@:@@@:)
- (YTQTMButton *)createButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector {
    return createButtonTop(NO, self, buttonId, accessibilityLabel, selector);
}

%new(@@:@@@:)
- (YTQTMButton *)createTextButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector {
    return createButtonTop(YES, self, buttonId, accessibilityLabel, selector);
}

%new(@@:@)
- (YTQTMButton *)button:(NSString *)tweakId {
    return nil;
}

%new(@@:@)
- (UIImage *)buttonImage:(NSString *)tweakId {
    return nil;
}

- (NSMutableArray *)topButtonControls {
    return topControls(self, %orig);
}

- (NSMutableArray *)topControls {
    return topControls(self, %orig);
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    CGFloat alpha = canceledState || !visible ? 0.0 : 1.0;
    for (NSString *name in topButtons)
        [self button:name].alpha = UseTopButton(name) ? alpha : 0;
    %orig;
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%new(@@:@@@:)
- (YTQTMButton *)createButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector {
    return createButtonBottom(NO, self, buttonId, accessibilityLabel, selector);
}

%new(@@:@@@:)
- (YTQTMButton *)createTextButton:(NSString *)buttonId accessibilityLabel:(NSString *)accessibilityLabel selector:(SEL)selector {
    return createButtonBottom(YES, self, buttonId, accessibilityLabel, selector);
}

%new(@@:@)
- (YTQTMButton *)button:(NSString *)tweakId {
    return nil;
}

%new(@@:@)
- (UIImage *)buttonImage:(NSString *)tweakId {
    return nil;
}

- (NSMutableArray *)rightIcons {
    NSMutableArray *icons = %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name)) {
            YTQTMButton *button = [self button:name];
            [icons insertObject:button atIndex:0];
        }
    }
    return icons;
}

- (void)updateIconVisibility {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].hidden = NO;
    }
}

- (void)updateIconsHiddenAttribute {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].hidden = NO;
    }
}

- (void)hideScrubber {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].alpha = 0;
    }
}

- (void)setPeekableViewVisible:(BOOL)visible {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].alpha = visible ? 1 : 0;
    }
}

- (void)setPeekableViewVisible:(BOOL)visible fullscreenButtonVisibleShouldMatchPeekableView:(BOOL)match {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].alpha = visible ? 1 : 0;
    }
}

- (void)peekWithShowScrubber:(BOOL)scrubber setControlsAbovePlayerBarVisible:(BOOL)visible {
    %orig;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name))
            [self button:name].alpha = visible ? 1 : 0;
    }
}

- (void)layoutSubviews {
    %orig;
    CGFloat multiFeedWidth = [self respondsToSelector:@selector(multiFeedElementView)] ? [self multiFeedElementView].frame.size.width : 0;
    YTQTMButton *enter = [self enterFullscreenButton];
    CGFloat shift = 0;
    CGRect frame = CGRectZero;
    if ([enter yt_isVisible]) {
        frame = enter.frame;
        shift = multiFeedWidth + (2 * frame.size.width);
    } else {
        YTQTMButton *exit = [self exitFullscreenButton];
        if ([exit yt_isVisible]) {
            frame = exit.frame;
            shift = multiFeedWidth + (2 * frame.size.width);
        }
    }
    if (CGRectIsEmpty(frame) || frame.origin.x <= 0 || frame.origin.y < -4) return;
    frame.origin.x -= shift;
    for (NSString *name in bottomButtons) {
        if (UseBottomButton(name)) {
            [self button:name].frame = frame;
            frame.origin.x -= (2 * frame.size.width);
            if (frame.origin.x < 0) frame.origin.x = 0;
        }
    }
}

%end

%end

%group Settings

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks)))
        return %orig;
    NSMutableArray *mutableCategories = %orig.mutableCopy;
    [mutableCategories insertObject:@(YTVideoOverlaySection) atIndex:0];
    return mutableCategories.copy;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = [order mutableCopy];
        [mutableOrder insertObject:@(YTVideoOverlaySection) atIndex:insertIndex + 1];
        order = mutableOrder.copy;
    }
    return order;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
+ (void)registerTweak:(NSString *)tweakId {
    [tweaks addObject:tweakId];
}

%new(v@:@B)
+ (void)setTweak:(NSString *)tweakId hasOwnToggle:(BOOL)hasOwnToggle {
    if (hasOwnToggle)
        [tweaksWithOwnToggle addObject:tweakId];
}

%new(v@:@)
- (void)updateYTVideoOverlaySectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = TweakBundle(@"YTVideoOverlay");
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
    for (NSString *name in tweaks) {
        NSBundle *bundle = TweakBundle(name);
        YTSettingsSectionItem *header = [YTSettingsSectionItemClass itemWithTitle:name
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:nil];
        header.enabled = NO;
        [sectionItems addObject:header];
        if (![tweaksWithOwnToggle containsObject:name]) {
            YTSettingsSectionItem *master = [YTSettingsSectionItemClass switchItemWithTitle:_LOC(bundle, @"ENABLED")
                titleDescription:nil
                accessibilityIdentifier:nil
                switchOn:TweakEnabled(name)
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey(name)];
                    return YES;
                }
                settingItemId:0];
            [sectionItems addObject:master];
        }
        YTSettingsSectionItem *position = [YTSettingsSectionItemClass itemWithTitle:_LOC(bundle, @"POSITION")
            accessibilityIdentifier:nil
            detailTextBlock:^NSString *() {
                return ButtonPosition(name) ? LOC(@"BOTTOM") : LOC(@"TOP");
            }
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSArray <YTSettingsSectionItem *> *rows = @[
                    [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"TOP") titleDescription:LOC(@"TOP_DESC") selectBlock:^BOOL (YTSettingsCell *top, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:PositionKey(name)];
                        [settingsViewController reloadData];
                        return YES;
                    }],
                    [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"BOTTOM") titleDescription:LOC(@"BOTTOM_DESC") selectBlock:^BOOL (YTSettingsCell *bottom, NSUInteger arg1) {
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:PositionKey(name)];
                        [settingsViewController reloadData];
                        return YES;
                    }]
                ];
                YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:_LOC(bundle, @"POSITION") pickerSectionTitle:nil rows:rows selectedItemIndex:ButtonPosition(name) parentResponder:[self parentResponder]];
                [settingsViewController pushViewController:picker];
                return YES;
            }];
        [sectionItems addObject:position];
    }
    NSString *title = LOC(@"VIDEO_OVERLAY");
    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_TV;
        [settingsViewController setSectionItems:sectionItems forCategory:YTVideoOverlaySection title:title icon:icon titleDescription:nil headerHidden:NO];
    } else
        [settingsViewController setSectionItems:sectionItems forCategory:YTVideoOverlaySection title:title titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTVideoOverlaySection) {
        [self updateYTVideoOverlaySectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

%end

%ctor {
    tweaks = [NSMutableArray array];
    tweaksWithOwnToggle = [NSMutableArray array];
    topButtons = [NSMutableArray array];
    bottomButtons = [NSMutableArray array];
    %init(Settings);
    %init(Top);
    %init(Bottom);
}

%dtor {
    [tweaks removeAllObjects];
    [tweaksWithOwnToggle removeAllObjects];
    [topButtons removeAllObjects];
    [bottomButtons removeAllObjects];
}
