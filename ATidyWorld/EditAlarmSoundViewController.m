//
//  EditAlarmSoundViewController_iPhone.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-01-28.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "EditAlarmSoundViewController.h"
#import "MediaCellView.h"
#import "RSPlist.h"
#import "ClockConstants.h"
#import "AppDelegate.h"
#import "Constants.h"

NSUInteger const kSoundEffectSegmentIndex = 0;
NSUInteger const kMusicSegmentIndex = 1;

@implementation EditAlarmSoundViewController

@synthesize soundList = _soundList,
            musicList = _musicList,
            mediaItemCollection = _mediaItemCollection,
            lastSelectedIndexPath = _lastSelectedIndexPath,
            selectedMediaID = _selectedMediaID,
            selectedMediaName = _selectedMediaName,
            soundTypeControl = _soundTypeControl,
            mediaCell = _mediaCell,
            audioPlayer = _audioPlayer,
            editButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _musicList = [[NSMutableArray alloc] initWithCapacity:0];
        DLog(@"Reading Alarm Sound Effects PList");
        self.soundList = (NSArray *)[RSPlist readPlist:kAlarmSoundEffectPList];
        DLog(@"Reading Alarm Music PList");
        NSArray *mediaIDArray = (NSArray *)[RSPlist readPlist:kAlarmMediaPList];
        [self loadMediaWithIDs:mediaIDArray];
        
        self.lastSelectedIndexPath = [NSIndexPath indexPathForRow:9999 inSection:9999];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"CELL_TITLE_ALARM_SOUND", @"Sound Title");
    [self.soundTypeControl setTitle:NSLocalizedString(@"SEGMENT_TITLE_SOUNDS", @"Sounds") forSegmentAtIndex:0];
    [self.soundTypeControl setTitle:NSLocalizedString(@"SEGMENT_TITLE_SONGS", @"Songs") forSegmentAtIndex:1];
    [self.navigationItem setRightBarButtonItem:editButton];
    [self.editButton setEnabled:NO];
    
    if ([_musicList count] == 0)
    {
        // Present alert view informing the user they have no music but should add some.
        UIAlertView *noMediaAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_TITLE_NO_MUSIC_IN_LIBRARY", @"Add Music Title")
                                                                   message:NSLocalizedString(@"ALERT_TEXT_NO_MUSIC_IN_LIBRARY", @"Add music to your library")
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
        [noMediaAlertView show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.soundTypeControl = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackView:@"Edit Alarm Sound"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAudio];
    [self saveMediaList];
    [_delegate didReturnFromEditingAlarmElement:@"sound"
                                      withValue:[NSDictionary dictionaryWithObjectsAndKeys: _selectedMediaName, @"name", _selectedMediaID, @"id", nil]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch (_soundTypeControl.selectedSegmentIndex) {
        case kMusicSegmentIndex:
            return 1;
            break;
        case kSoundEffectSegmentIndex:
        default:
            return 1;
            break;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_soundTypeControl.selectedSegmentIndex) {
        case kSoundEffectSegmentIndex:
            return [_soundList count];
            break;
        case kMusicSegmentIndex:
            if (tableView.isEditing)
            {
                return [_musicList count] + 1;
            }
            else 
            {
                return [_musicList count];
            }
        default:
            return 0;
            break;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_soundTypeControl.selectedSegmentIndex)
    {
        case kMusicSegmentIndex:
        {
            if (indexPath.row < [_musicList count])
                return [self configureMusicCellViewForTableView:tableView atIndexPath:indexPath];
            else
                return [self configureAddMusicCellViewForTableView:tableView atIndexPath:indexPath];
            break;
        }
        case kSoundEffectSegmentIndex:
        default:
        {
            return [self configureSoundEffectCellViewForTableView:tableView atIndexPath:indexPath];
            break;
        }
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_soundTypeControl.selectedSegmentIndex)
    {
        case kMusicSegmentIndex:
        {
            return YES;
            break;
        }
        case kSoundEffectSegmentIndex:
        default:
        {
            return NO;
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        switch (_soundTypeControl.selectedSegmentIndex)
        {
            case kSoundEffectSegmentIndex:
                break;
            case kMusicSegmentIndex:
            {
                [_musicList removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                     withRowAnimation:UITableViewRowAnimationLeft];
            }
        }
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing)
    {
        if (_soundTypeControl.selectedSegmentIndex == kMusicSegmentIndex)
        {
            if (indexPath.row < [_musicList count])
                return UITableViewCellEditingStyleDelete;
            else
                return UITableViewCellEditingStyleInsert;
        }
    }
    return UITableViewCellEditingStyleNone;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    switch (_soundTypeControl.selectedSegmentIndex)
    {
        case kSoundEffectSegmentIndex:
            break;
        case kMusicSegmentIndex:
        {
            MPMediaItem *item = [_musicList objectAtIndex:fromIndexPath.row];
            [_musicList removeObject:item];
            if (toIndexPath.row >= [_musicList count])
            {
                [_musicList addObject:item];
            }
            else
            {
                [_musicList insertObject:item atIndex:toIndexPath.row];        
            }
        }
        default:
            break;
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    switch (_soundTypeControl.selectedSegmentIndex)
    {
        case kMusicSegmentIndex:
        {
            if (indexPath.row < [_musicList count])
                return YES;
            else
                return NO;
            break;
        }
        case kSoundEffectSegmentIndex:
        default:
            return NO;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_soundTypeControl.selectedSegmentIndex == kMusicSegmentIndex) &&
        (indexPath.row == [_musicList count]))
    {
        [self addSoundButtonPressed:tableView];
    }
    else
    {
        [self selectMediaItemFromTableView:tableView atIndexPath:indexPath];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}

#pragma mark - MPMediaPickerControllerDelegate Methods
- (void)mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection 
{
    [self dismissModalViewControllerAnimated: YES];
    //[self updatePlayerQueueWithMediaCollection: collection];
    DLog(@"Music List contains %d items, adding %d items", [_musicList count], [collection count]);
    [_musicList addObjectsFromArray:[collection items]];
    DLog(@"Music List now contains %d items", [_musicList count]);
    [self removeDuplicateIds];
    [_tableView reloadData];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker 
{
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - Music Datasource Methods
- (UITableViewCell *)configureSoundEffectCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SoundEffectCellIdentifier = @"SoundEffectCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SoundEffectCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:SoundEffectCellIdentifier];
    }
    NSDictionary *soundItem = [_soundList objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString([soundItem valueForKey:kSoundEffectTitleKey] , @"Sound Effect Name");
    NSString *soundURL = [NSString stringWithFormat:@"%@", 
                                    [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", 
                                              [[NSBundle mainBundle] resourcePath],
                                              [soundItem valueForKey:kSoundEffectFilenameKey]]] ];
    if ([soundURL isEqualToString:_selectedMediaID])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.lastSelectedIndexPath = indexPath;
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (UITableViewCell *)configureMusicCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MediaCellIdentifier = @"MediaCellView";
    
    MediaCellView *cell = [tableView dequeueReusableCellWithIdentifier:MediaCellIdentifier];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"MediaCellView" owner:self options:nil];
        cell = _mediaCell;
        
        self.mediaCell = nil;
    }
    
    MPMediaItem *mediaItem = [_musicList objectAtIndex:indexPath.row];
    NSString *songID = [NSString stringWithFormat:@"%@", [mediaItem valueForProperty:MPMediaItemPropertyAssetURL]];
    if ([songID isEqualToString:_selectedMediaID])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.lastSelectedIndexPath = indexPath;
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.songTitleLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    cell.songArtistLabel.text = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    
    MPMediaItemArtwork *artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
    [cell.artworkImageView setImage:[artwork imageWithSize:cell.imageView.bounds.size]];
    
    return cell;
}

- (UITableViewCell *)configureAddMusicCellViewForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddMusicCellIdentifier = @"AddMusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddMusicCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:AddMusicCellIdentifier];
    }
    cell.textLabel.text = NSLocalizedString(@"BUTTON_TEXT_ADD_MUSIC", @"Add Music from Library");
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    cell.backgroundView = backgroundView;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.accessoryView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)selectMediaItemFromTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    // Handle Song Selection
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    NSURL *assetURL;
    switch (_soundTypeControl.selectedSegmentIndex)
    {
        case kMusicSegmentIndex:
        {
            MPMediaItem *mediaItem = [_musicList objectAtIndex:indexPath.row];
            self.selectedMediaName = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
            assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
            break;
        }
        default:
        {
            NSDictionary *soundItem = [_soundList objectAtIndex:indexPath.row];
            self.selectedMediaName = NSLocalizedString([soundItem valueForKey:kSoundEffectTitleKey] , @"Sound Effect Name");
            assetURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", 
                                               [[NSBundle mainBundle] resourcePath],
                                               [soundItem valueForKey:kSoundEffectFilenameKey]]];
            break;
        }
    }
    if (indexPath.row != _lastSelectedIndexPath.row)
    {
        [[tableView cellForRowAtIndexPath:_lastSelectedIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
        [self playAudioFromURL:assetURL];  
    }
    else 
    {
        if (_audioPlaying)
        {
            [self stopAudio];            
        }
        else
        {
            [self playAudioFromURL:assetURL];
        }
    }
    self.selectedMediaID = [NSString stringWithFormat:@"%@", assetURL];
    self.lastSelectedIndexPath = nil;
    self.lastSelectedIndexPath = indexPath;
}

#pragma mark - IBActions
- (IBAction)soundTypeControlPressed:(id)sender
{
    DLog(@"");
    switch ([_soundTypeControl selectedSegmentIndex])
    {
        case kSoundEffectSegmentIndex:
        {
            [self.editButton setEnabled:NO];
            break;
        }
        case kMusicSegmentIndex:
        {
            [self.editButton setEnabled:YES];
            break;
        }
        default:
            break;
    }
    [_tableView reloadData];
}

- (IBAction)addSoundButtonPressed:(id)sender
{
    DLog(@"");
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];    
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: YES];
    picker.prompt = NSLocalizedString (@"PROMPT_TEXT_SELECT_MEDIA", "Prompt in media item picker");
    [self presentModalViewController:picker animated:YES];
    if (ANALYTICS_GOOGLE_ON)
        [[GAI sharedInstance].defaultTracker trackEventWithCategory:@"Content"
                                                         withAction:@"AlarmSoundAdds"
                                                          withLabel:@"Alarm Sound Adds"
                                                          withValue:[NSNumber numberWithInt:1]];
}

- (IBAction)editButtonPressed:(id)sender
{
    DLog(@"");
    [_tableView setEditing:YES animated:YES];
    
    // Change edit button to Done
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self 
                                                                                action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)doneButtonPressed:(id)sender
{
    DLog(@"");
    [_tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

#pragma mark - Property List Handling
- (void)loadMediaWithIDs:(NSArray *)persistentIds
{
    if ([persistentIds count] > 0)
    {
        NSMutableArray *mediaItems = [NSMutableArray arrayWithCapacity:0];
        for (NSNumber *persistentId in persistentIds){
            MPMediaQuery *query = [[MPMediaQuery alloc] init];
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:persistentId 
                                                                                   forProperty:MPMediaItemPropertyPersistentID];
            [query addFilterPredicate:predicate];
            [mediaItems addObjectsFromArray:[query items]];
        }
        [self.musicList removeAllObjects];
        [self.musicList addObjectsFromArray:mediaItems];
        [self removeDuplicateIds];
    }
}

- (void)saveMediaList
{
    NSMutableArray *mediaIDArray = [NSMutableArray array];

    for (MPMediaItem *item in _musicList)
    {
        [mediaIDArray addObject:[item valueForProperty:MPMediaItemPropertyPersistentID]];
    }
    [RSPlist writePlist:mediaIDArray fileName:kAlarmMediaPList];
}

- (void)removeDuplicateIds
{
    NSArray *copy = [_musicList copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([_musicList indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [_musicList removeObjectAtIndex:index];
        }
        index--;
    }
}

#pragma mark - Audio Player Methods
- (void)playAudioFromURL:(NSURL *)assetURL
{
    if (!self.audioPlayer)
    {
        _audioPlayer = [[AVPlayer alloc] init];
    }
    AVPlayerItem *newPlayerItem = [AVPlayerItem playerItemWithURL:assetURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedAVPlayerDidPlayToEndTimeNotification:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification 
                                               object:newPlayerItem];
    [_audioPlayer replaceCurrentItemWithPlayerItem:newPlayerItem];
    [_audioPlayer play];
    _audioPlaying = YES;
    self.lastSelectedIndexPath = [NSString stringWithFormat:@"%@", assetURL];
}

- (void)stopAudio
{
    [self.audioPlayer pause];
    self.audioPlayer = nil;
    _audioPlaying = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)receivedAVPlayerDidPlayToEndTimeNotification:(NSNotification *)notification
{
    DLog(@"receivedAVPlayerDidPlayToEndTimeNotification");
    [self stopAudio];
}

@end
