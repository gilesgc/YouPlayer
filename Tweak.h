@interface YTInlinePlayerBarView : UIView {
    UIView *_playingProgress;
    UIView *_scrubberCircle;
}
@property UIView *scrubberCircle;
@end

@interface YTInlinePlayerBarContainerView : UIView
-(YTInlinePlayerBarView *) playerBar;
@end
