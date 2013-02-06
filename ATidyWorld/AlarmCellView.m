//
//  AlarmCellView.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-14.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "AlarmCellView.h"

@implementation AlarmCellView

@synthesize backgroundImageView,
            timeLabel,
            ampmLabel,
            frequencyLabel,
            titleLabel,
            enabledSwitch,
            problemIcon;

static const uint kHorizontalMarginPadding = 10;
static const uint kVerticalMarginPadding = 4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.ampmLabel sizeToFit];
    [self.timeLabel sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGRect frequencyLabelRect;
    CGRect timeLabelRect;
    CGRect titleLabelRect;
    CGRect ampmLabelRect;
    CGRect problemIconRect;
    
    // Set default layout, presuming there is a frequency label set
    if ([self.frequencyLabel.text length] > 0)
    {
        frequencyLabelRect = CGRectMake(self.contentView.bounds.origin.x + kHorizontalMarginPadding,
                                        (self.contentView.bounds.size.height / 2) - (self.frequencyLabel.frame.size.height / 2),
                                        self.frequencyLabel.frame.size.width,
                                        self.frequencyLabel.frame.size.height);
        timeLabelRect = CGRectMake(frequencyLabelRect.origin.x,
                                   (frequencyLabelRect.origin.y - self.timeLabel.frame.size.height - self.timeLabel.font.descender),
                                   self.timeLabel.frame.size.width,
                                   self.timeLabel.frame.size.height);
        titleLabelRect = CGRectMake(frequencyLabelRect.origin.x,
                                    (self.frequencyLabel.frame.origin.y + self.frequencyLabel.frame.size.height),
                                    self.titleLabel.frame.size.width,
                                    self.titleLabel.frame.size.height);
    }
    // Re-align time and title to center if no frequency is set
    else
    {
        // Move time and title to centered
        timeLabelRect = CGRectMake(self.contentView.bounds.origin.x + kHorizontalMarginPadding,
                                   (self.contentView.bounds.size.height / 2) - self.timeLabel.frame.size.height - self.timeLabel.font.descender,
                                   self.timeLabel.frame.size.width,
                                   self.timeLabel.frame.size.height);
        titleLabelRect = CGRectMake(timeLabelRect.origin.x,
                                    (self.contentView.bounds.size.height / 2) - self.titleLabel.font.descender,
                                    self.titleLabel.frame.size.width,
                                    self.titleLabel.frame.size.height);        
    }
    // AM/PM label appears to the right of timeLabel, aligned with the baseline of timeLabel
    ampmLabelRect = CGRectMake((self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width),
                               (timeLabelRect.origin.y + self.timeLabel.frame.size.height + self.timeLabel.font.descender) - (self.ampmLabel.frame.size.height + self.ampmLabel.font.descender),
                               self.ampmLabel.frame.size.width,
                               self.ampmLabel.frame.size.height);
    
    // Problem icon appears to the right of the ampmLabel if it exists or to the right of timeLabel otherwise
    problemIconRect = CGRectMake((self.ampmLabel.frame.origin.x + self.ampmLabel.frame.size.width + 8),
                                 (self.timeLabel.frame.origin.y + (self.timeLabel.frame.size.height / 2) - (self.problemIcon.frame.size.height / 2)),
                                 problemIcon.frame.size.width,
                                 problemIcon.frame.size.height);

    [self.ampmLabel setFrame:ampmLabelRect];
    [self.titleLabel setFrame:titleLabelRect];
    [self.timeLabel setFrame:timeLabelRect];
    [self.problemIcon setFrame:problemIconRect];
    
    // FOR DEBUGGING THE LAYOUT
//    [self.timeLabel setBackgroundColor:[UIColor yellowColor]];
//    [self.ampmLabel setBackgroundColor:[UIColor orangeColor]];
//    [self.titleLabel setBackgroundColor:[UIColor cyanColor]];
//    [self.frequencyLabel setBackgroundColor:[UIColor greenColor]];
    DLog(@"");
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.enabledSwitch setHidden:editing];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self applyLabelDropShadow:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self applyLabelDropShadow:selected];
}

#pragma mark - Custom Methods
- (void)applyLabelDropShadow:(BOOL)applyDropShadow
{
    self.timeLabel.shadowColor = applyDropShadow ? nil : [UIColor whiteColor];
    self.frequencyLabel.shadowColor = applyDropShadow ? nil : [UIColor whiteColor];
    self.titleLabel.shadowColor = applyDropShadow ? nil : [UIColor whiteColor];
}
@end
