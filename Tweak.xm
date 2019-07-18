#import <substrate.h>

static BOOL doIHaveThumbnail = NO;
static UIImageView *theImage;
static BOOL imageWasPlaced = NO;

@interface YTInlinePlayerBarView : UIView {
    UIView *_playingProgress;
    UIView *_scrubberCircle;
}
@property UIView *scrubberCircle;
@end

@interface YTInlinePlayerBarContainerView : UIView
-(YTInlinePlayerBarView *) playerBar;
@end

%hook YTInlinePlayerBarContainerView

- (YTInlinePlayerBarView *)playerBar {
    
    YTInlinePlayerBarView *playerBar = %orig;
    
    if(theImage && !imageWasPlaced) {
        [theImage setFrame:[playerBar scrubberCircle].bounds];
        MSHookIvar<UIView *>(playerBar, "_scrubberCircle") = theImage;
        [playerBar addSubview:theImage];
        imageWasPlaced = YES;
    }
    
    [MSHookIvar<UIView *>(playerBar, "_playingProgress") setBackgroundColor:[UIColor blueColor]];

    return playerBar;
}

%end

@interface YTImageView : UIView
-(UIImageView *)imageView;
@end

%hook YTImageView

-(void)layoutSubviews {
    %orig;
    //grab random image from app for testing
    if(!doIHaveThumbnail && [[self imageView] image]) {
        theImage = [[UIImageView alloc] initWithImage:[[self imageView] image]];
        doIHaveThumbnail = YES;
    }
}

%end