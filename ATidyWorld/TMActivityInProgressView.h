//
//  TMActivityInProgressView.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-11.
//
//

#import <UIKit/UIKit.h>

@interface TMActivityInProgressView : UIView
{
    UIActivityIndicatorView *activityIndicatorView;
    UILabel                 *messageLabel;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

/// Fades the view into the display
- (void)showView;
/// Fades the view out from the display
- (void)hideView;

@end
