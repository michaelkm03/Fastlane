//
//  VComposeMessageViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VComposeMessageViewController.h"


@interface VComposeMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (strong, nonatomic) NSData* mediaData;
@property (strong, nonatomic) NSString* mediaType;
@end

@implementation VComposeMessageViewController
{
    CGSize      _keyboardSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.delegate  =   self;
    self.textView.keyboardDismissMode   =   UIScrollViewKeyboardDismissModeInteractive;
    self.textView.scrollEnabled =   YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    // make the keyboard appear when the application launches
    [super viewWillAppear:animated];

    // start editing the UITextView
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)compose:(id)sender
{
    [self.delegate didComposeWithText:self.textView.text data:_mediaData extension:_mediaType];
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    if (self.textView.inputAccessoryView == nil)
        self.textView.inputAccessoryView = self.accessoryView;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView
{
    [aTextView resignFirstResponder];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [textView scrollRangeToVisible:range];
    return YES;
}

#pragma mark - Responding to keyboard events

- (void)keyboardDidShow:(NSNotification *)notification
{
    _keyboardSize   =   [[notification userInfo][@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue].size;
    [self updateTextViewSize];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _keyboardSize   =   CGSizeMake(0.0, 0.0);
    [self updateTextViewSize];
}

- (void)updateTextViewSize
{
    UIInterfaceOrientation  orientation =   [UIApplication sharedApplication].statusBarOrientation;
    CGFloat     keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? _keyboardSize.width : _keyboardSize.height;
    self.textView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight);
}

#pragma mark - Accessory view action

- (IBAction)cameraButtonClicked:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    else
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

    imagePicker.videoMaximumDuration = 10.0f;
    
//    TODO: install reachability in the codebase
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    [reachability startNotifier];
//    NetworkStatus status = [reachability currentReachabilityStatus];
//    //Apple documention says use medium for WIFI and low for 3g.
//    if (status == NotReachable)
//        return;
//    else if (status == ReachableViaWiFi)
//        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
//    else if (status == ReachableViaWWAN)
//        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if ([_mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        //Use the edited image if it exists, otherwise use the original
        UIImage* imageToSave = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        if (!imageToSave)
            imageToSave = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];;
        
        _mediaData = [NSData dataWithData:UIImagePNGRepresentation(imageToSave)];
        _mediaType = @"png";
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    // Handle a movie capture
    else if ([_mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
             [_mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL* videoURL = [info objectForKey: UIImagePickerControllerMediaURL];
        
        //this is the binary data for the video
        _mediaData = [NSData dataWithContentsOfURL:videoURL];
        _mediaType = [videoURL pathExtension];
        
        //save the data
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([videoURL path]))
        {
            UISaveVideoAtPathToSavedPhotosAlbum ([videoURL path], nil, nil, nil);
        }
    }
    else //We didn't get valid data, so reset it
    {
        _mediaType = nil;
        _mediaData = nil;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
