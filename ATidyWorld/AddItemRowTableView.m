//
//  AlarmListTableView.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-05-13.
//  Copyright (c) 2012 The Great-West Life Assurance Company. All rights reserved.
//

#import "AddItemRowTableView.h"

@implementation AddItemRowTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing)
    {
        NSArray *paths = [NSArray arrayWithObject:
                          [NSIndexPath indexPathForRow:[self numberOfRowsInSection:0] inSection:0]];
        [self insertRowsAtIndexPaths:paths 
                                withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        NSArray *paths = [NSArray arrayWithObject:
                          [NSIndexPath indexPathForRow:[self numberOfRowsInSection:0]-1 inSection:0]];
        [self deleteRowsAtIndexPaths:paths 
                                withRowAnimation:UITableViewRowAnimationTop];
    }
}

@end
