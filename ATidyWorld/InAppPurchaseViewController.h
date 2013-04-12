//
//  InAppPurchaseViewController.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-04-09.
//
//

#import <UIKit/UIKit.h>

@class TMActivityInProgressView;

@interface InAppPurchaseViewController : UITableViewController
{
    TMActivityInProgressView *_activityProgressView;
}

@property (nonatomic, strong) TMActivityInProgressView *activityProgressView;

@end
