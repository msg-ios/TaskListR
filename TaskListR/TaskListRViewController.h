//
//  TaskListRViewController.h
//  TaskListR
//
//  Created by Marco S. Graciano on 3/5/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TaskListRViewController : UITableViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    BOOL newMedia;
    BOOL recordExists;
}

@property NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSURL *soundFileURL;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) NSIndexPath *pathToPlayingCell;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

- (IBAction)useCameraRoll:(id)sender;
- (IBAction)useCamera:(id)sender;
- (IBAction)recordAudio:(id)sender;
- (void)playAudio:(UIButton *)button;

@end
