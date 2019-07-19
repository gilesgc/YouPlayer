#import "Tweak.h"
#import <substrate.h>
#import <libimagepicker.h>
#import <libcolorpicker.h>

static BOOL tweakIsEnabled = YES;
static BOOL didSetIcon = NO;
static UIImageView *playerBarIcon;
static UIColor *playerBarColor;
static float iconSizeMultiplier = 1.5f;

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gilesgc.youplayer.plist"];
    
    tweakIsEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
    playerBarIcon = [prefs objectForKey:@"playerIcon"] ? 
        [[UIImageView alloc] initWithImage:LIPParseImage([prefs objectForKey:@"playerIcon"])] : nil;
    iconSizeMultiplier = [prefs objectForKey:@"iconSizeMultiplier"] ? [[prefs objectForKey:@"iconSizeMultiplier"] floatValue] : 1.5f;
    
    NSDictionary *colorPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gilesgc.youplayer.color.plist"];
    playerBarColor = LCPParseColorString([colorPrefs objectForKey:@"playerColor"], @"#FF0000");
}

%hook YTInlinePlayerBarContainerView

- (YTInlinePlayerBarView *)playerBar {
    
    YTInlinePlayerBarView *playerBar = %orig;

    if(!tweakIsEnabled)
        return playerBar;
    
    if(playerBarIcon && !didSetIcon) {        
        [[playerBar scrubberCircle] setHidden:YES];

        //Preserve image ratio when setting size
        float iconSizeRatio = [[playerBarIcon image] size].height / [[playerBarIcon image] size].width;
        CGRect newFrame = [playerBar scrubberCircle].bounds;
        newFrame.size.height *= iconSizeMultiplier;
        newFrame.size.width = newFrame.size.height / iconSizeRatio;
        [playerBarIcon setFrame:newFrame];

        //Set the circle UIView to a UIImageView. That way it will have the same behavior but with an image
        MSHookIvar<UIView *>(playerBar, "_scrubberCircle") = playerBarIcon;
        [playerBar addSubview:playerBarIcon];

        didSetIcon = YES;
    }
    
    [playerBarIcon setBackgroundColor:[UIColor clearColor]];

    //set progress bar color
    [MSHookIvar<UIView *>(playerBar, "_playingProgress") setBackgroundColor:playerBarColor];

    return playerBar;
}

%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.gilesgc.youplayer/prefChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    %init;
}