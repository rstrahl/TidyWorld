//
//  MusicCellView.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-29.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "MediaCellView.h"

@implementation MediaCellView

@synthesize artworkImageView,
            songTitleLabel,
            songArtistLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
