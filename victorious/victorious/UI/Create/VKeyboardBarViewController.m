//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VCameraViewController.h"
#import "VObjectManager+Comment.h"
#import "VKeyboardBarViewController.h"

//#import "VSequence.h"
//#import "VConstants.h"

#import "VLoginViewController.h"

@interface VKeyboardBarViewController() <UITextFieldDelegate>
@property (weak, nonatomic, readwrite) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (nonatomic, strong) NSString*  mediaExtension;
@property (nonatomic, strong) NSURL* mediaURL;

//@property (weak, nonatomic) IBOutlet UICollectionView* stickersView;
//@property (nonatomic, strong) NSArray* stickers;
//@property (nonatomic, strong) NSData* selectedSticker;
@end

@implementation VKeyboardBarViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
    
//    [self.stickersView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"stickerCell"];
    self.mediaButton.layer.cornerRadius = 2;
    self.mediaButton.clipsToBounds = YES;
    // populate stickers array
    
//    [self.stickersView reloadData];
}

- (IBAction)cameraButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    [self.textField resignFirstResponder];
    
//    [super cameraButtonAction:sender];
}

- (IBAction)sendButtonAction:(id)sender
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    [self.textField resignFirstResponder];
    [self.delegate keyboardBar:self didComposeWithText:self.textField.text mediaURL:self.mediaURL mediaExtension:self.mediaExtension];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textField.text = nil;
    self.mediaExtension = nil;
    self.mediaURL = nil;
}

- (void)cameraPressed:(id)sender
{
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL, NSString *mediaExtension)
    {
        if (finished)
        {
            self.mediaURL = capturedMediaURL;
            self.mediaExtension = mediaExtension;
            [self.mediaButton setImage:previewImage forState:UIControlStateNormal];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

@end
