//
//  VComposeViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VComposeViewController.h"
#import "VObjectManager+Comment.h"
#import "VSequence.h"
#import "VConstants.h"

@interface VComposeViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView* stickersView;
@property (weak, nonatomic) NSData* media;
@property (nonatomic, strong) NSString*  mediaExtension;
@property (nonatomic, strong) NSArray* stickers;
@property (nonatomic, strong) NSData* selectedSticker;
@end

@implementation VComposeViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
    
    // populate stickers array
}

- (IBAction)cameraButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
    
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
     else
         controller.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    controller.allowsEditing = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)stickerButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
    
    self.stickersView.dataSource = self;
    self.stickersView.delegate = self;
    
    //  Post UICollectionView populated with stickers
}

- (IBAction)sendButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
    if([self.textField.text length])
    {
        [self.delegate didComposeWithText:self.textField.text data:self.selectedSticker mediaExtension:self.mediaExtension];
        self.textField.text = nil;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    
    self.mediaExtension = CFBridgingRelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(mediaType), kUTTagClassFilenameExtension));

    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        UIImage* imageToSave = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];

        self.media = UIImagePNGRepresentation(imageToSave);
        self.mediaExtension = VConstantMediaExtensionPNG;
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        self.media = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        self.mediaExtension = VConstantMediaExtensionMOV;
    }
    
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UICollectionViewDelegate

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//
//- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout;

@end
