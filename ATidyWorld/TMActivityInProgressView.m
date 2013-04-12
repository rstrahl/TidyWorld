//
//  TMActivityInProgressView.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-11.
//
//

#import "TMActivityInProgressView.h"

@implementation TMActivityInProgressView

@synthesize messageLabel = _messageLabel,
            activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        
        // Add the activity indicator at the center point of the view
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGRect indicatorFrame = self.activityIndicator.frame;
        indicatorFrame.origin.x = (frame.size.width / 2) - (indicatorFrame.size.width / 2);
        indicatorFrame.origin.y = (frame.size.height / 2) - (indicatorFrame.size.height / 2);
        self.activityIndicator.frame = indicatorFrame;
        self.activityIndicator.backgroundColor = [UIColor clearColor];
        [self addSubview:self.activityIndicator];
        
        // Add the status label below the activity indicator
        self.messageLabel = [[UILabel alloc] init];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.messageLabel setShadowOffset:CGSizeMake(1, 1)];
        [self.messageLabel setTextColor:[UIColor whiteColor]];
        [self.messageLabel setNumberOfLines:2];
        CGFloat labelWidth = (frame.size.width * 0.75);
        CGFloat labelHeight = 26;
        self.messageLabel.frame = CGRectMake((frame.size.width / 2) - (labelWidth / 2),
                                             (indicatorFrame.origin.y + indicatorFrame.size.height + 4),
                                             labelWidth,
                                             labelHeight);
        self.messageLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.messageLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)showView
{
    if (self.hidden)
    {
        [self.activityIndicator startAnimating];
        self.hidden = NO;
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)hideView
{
    if (!self.hidden)
    {
        [self.activityIndicator stopAnimating];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             self.hidden = YES;
                         }];
    }
}

@end
