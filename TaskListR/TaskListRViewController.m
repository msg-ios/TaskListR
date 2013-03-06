//
//  TaskListRViewController.m
//  TaskListR
//
//  Created by Marco S. Graciano on 3/5/13.
//  Copyright (c) 2013 MSG. All rights reserved.
//

#import "TaskListRViewController.h"
#import "TaskCell.h"
#import "Task.h"

@interface TaskListRViewController ()  <NSFetchedResultsControllerDelegate>
@property NSFetchedResultsController *fetchedResultsController;
@end

@implementation TaskListRViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Task List", nil);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"completedAt" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    self.photoView.image = [UIImage imageNamed:@"placeholder.jpg"];
    
    //AVAudioRecorder initialization
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    _soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatAppleIMA4],
                                    AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:16000.0],
                                    AVSampleRateKey,
                                    nil];
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:_soundFileURL
                      settings:recordSettings
                      error:&error];
    _audioRecorder.delegate = self;
    recordExists = NO;
    _statusLabel.text = @"No record.";
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [_audioRecorder prepareToRecord];
    }

}

- (void)viewDidUnload {
    [self setRecordButton:nil];
    [self setStatusLabel:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self.fetchedResultsController sections]count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections]objectAtIndex:section]numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TaskCell";
    
    TaskCell *cell = (TaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell.playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    TaskCell *taskCell = (TaskCell *)cell;
    taskCell.taskNameLabel.text = task.text;
    taskCell.taskNameLabel.textColor = [task isCompleted] ? [UIColor lightGrayColor] : [UIColor blackColor];
    taskCell.taskPhoto.image = [[UIImage alloc]initWithData:task.imageData];
    
    if (task.audioData == nil) {
        taskCell.playButton.hidden = YES;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]     withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]    withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]    withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]     withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.managedObjectContext performBlock:^{
        Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        task.completed = !task.completed;
        [self.managedObjectContext save:nil];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = [textField.text copy];
    textField.text = nil;
    [textField resignFirstResponder];
    
    UIImage *photo = self.photoView.image;
    NSData *taskPhoto = UIImageJPEGRepresentation(photo, 1.0);
    
    [self.managedObjectContext performBlock:^{
        NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
        [managedObject setValue:text forKey:@"text"];
        [managedObject setValue:taskPhoto forKey:@"imageData"];
    
        if (recordExists) {
            NSData *audioData = [[NSData alloc] initWithContentsOfURL:_soundFileURL];
            [managedObject setValue:audioData forKey:@"audioData"];
            recordExists = NO;
        }
    
        [self.managedObjectContext save:nil];
    }];
    
    return YES;
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.photoView.image = image;
        
        //If a new photo is taken then it is saved into the Photos Album
        if (newMedia)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
}


-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save failed" message: @"Failed to save photo" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Button actions

- (IBAction)useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = NO;
    }
    
}

- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = YES;
    }
    
}


- (IBAction)recordAudio:(id)sender {
    if (!_audioRecorder.recording)
    {
        [_recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        //Records for 15 seconds max.
        _statusLabel.text =  @"Recording...";
        [_audioRecorder recordForDuration:(NSTimeInterval) 15.0];
    }
    else{
        [_audioRecorder stop];
        [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
        recordExists = YES;
    }

}


- (void)playAudio:(UIButton *)button{
    if (!_audioPlayer.playing)
    {
        TaskCell *owningCell = (TaskCell *)button.superview.superview;
        
        NSIndexPath *pathToCell = [self.tableView indexPathForCell:owningCell];
        _pathToPlayingCell = pathToCell;
        
        NSLog(@"path to cell: %d", pathToCell.row);
        
        Task *task = [self.fetchedResultsController objectAtIndexPath:pathToCell];
        
        NSData *audioData = [[NSData alloc] initWithData:task.audioData];
        NSLog(@"audioData: %@", task.audioData);
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc]
                            initWithData:audioData
                            error:&error];
        _audioPlayer.delegate = self;
        [_audioPlayer play];
        _statusLabel.text = @"Playing...";
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else{
        [_audioPlayer stop];
        [button setTitle:@"Play" forState:UIControlStateNormal];
        _statusLabel.text = @"Stopped";
    }
}

#pragma mark - AVAudioPlayerDelegate - AVAudioRecorderDelegate
-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _statusLabel.text = @"Stopped";
    TaskCell *cell = (TaskCell *)[self.tableView cellForRowAtIndexPath:_pathToPlayingCell];
    [cell.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player
error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
    _statusLabel.text = @"Error";
}

-(void)audioRecorderDidFinishRecording:
(AVAudioRecorder *)recorder
successfully:(BOOL)flag
{
    _recordButton.titleLabel.text = @"Record";
    if (flag) {
        recordExists = YES;
        _statusLabel.text = @"Record saved.";
    }
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}



@end
