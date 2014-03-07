//
//  VKeyboardBarViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VObjectManager+Comment.h"

#import "VKeyboardBarViewController.h"

//#import "VSequence.h"
//#import "VConstants.h"

#import "VLoginViewController.h"

@interface VKeyboardBarViewController() <UITextFieldDelegate>
@property (weak, nonatomic, readwrite) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *mediaButton;
@property (strong, nonatomic) NSData* media;
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
    [self.delegate didComposeWithText:self.textField.text data:self.media mediaExtension:self.mediaExtension mediaURL:self.mediaURL];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textField.text = nil;
    self.mediaExtension = nil;
    self.media = nil;
    self.mediaURL = nil;
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

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{
    self.media = data;
    self.mediaExtension = extension;
    [self.mediaButton setImage:previewImage forState:UIControlStateNormal];
    self.mediaURL = mediaURL;
}

@end
