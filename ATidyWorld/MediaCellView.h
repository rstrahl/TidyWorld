//
//  MusicCellView.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-29.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCellView : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, strong) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *songArtistLabel;

@end
