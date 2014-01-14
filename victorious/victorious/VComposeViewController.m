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
#import "VLoginViewController.h"

@interface VComposeViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
    
    [self.stickersView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"stickerCell"];
    // populate stickers array
    
    [self.stickersView reloadData];
}

- (IBAction)cameraButtonAction:(id)sender
{
    
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    [self.textField resignFirstResponder];
    
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
     else
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    controller.delegate = self;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    controller.allowsEditing = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)stickerButtonAction:(id)sender
{
    
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
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
        self.mediaExtension = nil;
        self.media = nil;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = info[UIImagePickerControllerMediaType];

    // Handle image capture
    if (CFStringCompare ((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        UIImage* imageToSave = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];

        self.media = UIImagePNGRepresentation(imageToSave);
        if (self.media)
            self.mediaExtension = VConstantMediaExtensionPNG;
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        self.media = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];
        if (self.media)
            self.mediaExtension = VConstantMediaExtensionMOV;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"stickerCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UICollectionViewDelegate

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100.0, 100.0);
}

// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end
