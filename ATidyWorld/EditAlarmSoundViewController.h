//
//  EditAlarmSoundViewController_iPhone.h
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-28.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "EditAlarmElementViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class MediaCellView;
@class AppDelegate;
@class AddItemRowTableView;

extern NSUInteger const kSoundEffectSegmentIndex;
extern NSUInteger const kMusicSegmentIndex;

@interface EditAlarmSoundViewController : EditAlarmElementViewController
    <MPMediaPickerControllerDelegate>
{
    AppDelegate                         *_appDelegate;
    NSArray                             *_soundList;
    NSMutableArray                      *_musicList;
    MPMediaItemCollection               *_mediaItemCollection;
    NSIndexPath                         *_lastSelectedIndexPath;
    NSString                            *_selectedMediaID;
    NSString                            *_selectedMediaName;
    
    UISegmentedControl                  *_soundTypeControl;
    MediaCellView                       *_mediaCell;

    BOOL                                _audioPlaying;
    AVPlayer                            *_audioPlayer;
}

@property (nonatomic, strong) NSArray                       *soundList;
@property (nonatomic, strong) NSMutableArray                *musicList;
@property (nonatomic, strong) MPMediaItemCollection         *mediaItemCollection;
@property (nonatomic, strong) NSIndexPath                   *lastSelectedIndexPath;
@property (nonatomic, strong) NSString                      *selectedMediaID;
@property (nonatomic, strong) NSString                      *selectedMediaName;
@property (nonatomic, strong) IBOutlet UISegmentedControl   *soundTypeControl;
@property (nonatomic, strong) IBOutlet UIBarButtonItem      *editButton;
@property (nonatomic, strong) IBOutlet MediaCellView        *mediaCell;
@property (nonatomic, strong) AVPlayer                      *audioPlayer;

- (UITableViewCell *)configureSoundEffectCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)configureMusicCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)configureAddMusicCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)selectMediaItemFromTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (IBAction)soundTypeControlPressed:(id)sender;
- (IBAction)addSoundButtonPressed:(id)sender;
- (IBAction)editButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

- (void)loadMediaWithIDs:(NSArray *)persistentIds;
- (void)saveMediaList;
- (void)removeDuplicateIds;

- (void)playAudioFromURL:(NSURL *)assetURL;
- (void)stopAudio;
- (void)receivedAVPlayerDidPlayToEndTimeNotification:(NSNotification *)notification;
@end
