#import "Tweak.h"
#import <substrate.h>
#import <libimagepicker.h>
#import <libcolorpicker.h>

static BOOL tweakIsEnabled = YES;
static BOOL didSetCustomViews = NO;
static UIImageView *playerBarIcon;
static CAGradientLayer *gradient;
static UIColor *progressBarLeftColor;
static UIColor *progressBarRightColor;
static float iconSizeMultiplier = 1.5f;

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gilesgc.youplayer.plist"];
    
    tweakIsEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
    playerBarIcon = [prefs objectForKey:@"playerIcon"] ? 
        [[UIImageView alloc] initWithImage:LIPParseImage([prefs objectForKey:@"playerIcon"])] : nil;
    iconSizeMultiplier = [prefs objectForKey:@"iconSizeMultiplier"] ? [[prefs objectForKey:@"iconSizeMultiplier"] floatValue] : 1.5f;
    
    NSDictionary *colorPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gilesgc.youplayer.color.plist"];
    progressBarLeftColor = LCPParseColorString([colorPrefs objectForKey:@"leftColor"], @"#FF0000");
    progressBarRightColor = LCPParseColorString([colorPrefs objectForKey:@"rightColor"], @"FF0000");
}

%hook YTInlinePlayerBarContainerView

- (YTInlinePlayerBarView *)playerBar {
    
    YTInlinePlayerBarView *playerBar = %orig;

    if(!tweakIsEnabled)
        return playerBar;
    
    if(playerBarIcon && !didSetCustomViews) {        
        [[playerBar scrubberCircle] setHidden:YES];

        //Preserve image ratio when setting size
        float iconSizeRatio = [[playerBarIcon image] size].height / [[playerBarIcon image] size].width;
        CGRect newFrame = [playerBar scrubberCircle].bounds;
        newFrame.size.height *= iconSizeMultiplier;
        newFrame.size.width = newFrame.size.height / iconSizeRatio;
        [playerBarIcon setFrame:newFrame];

        //Replace the circle UIView with a UIImageView so that it will have the same behavior but with an image
        MSHookIvar<UIView *>(playerBar, "_scrubberCircle") = playerBarIcon;
        [playerBar addSubview:playerBarIcon];

        //Set progress bar gradient
        UIView *progressBar = MSHookIvar<UIView *>(playerBar, "_playingProgress");

        gradient = [CAGradientLayer layer];
        gradient.frame = [[UIScreen mainScreen] bounds];
        gradient.colors = @[(id)progressBarLeftColor.CGColor, (id)progressBarRightColor.CGColor];
        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);

        //Clip gradient so it only shows on progress bar
        [progressBar.layer addSublayer:gradient];
        [progressBar setClipsToBounds:YES];

        didSetCustomViews = YES;
    }
    
    [playerBarIcon setBackgroundColor:[UIColor clearColor]];

    return playerBar;
}

%end

%hook YTNGWatchView

- (void)setFullscreen:(bool)arg1 {
    %orig;
    
    if(gradient) {
        //Update gradient width when sideways
        CGRect newFrame = gradient.frame;
        newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
        [gradient setFrame:newFrame];
    }
}

%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.gilesgc.youplayer/prefChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    %init;
}