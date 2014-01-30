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

#import "VSimpleLoginViewController.h"

@interface VKeyboardBarViewController() //<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
        [self presentViewController:[VSimpleLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    [self.textField resignFirstResponder];
    
//    [super cameraButtonAction:sender];
}

- (IBAction)sendButtonAction:(id)sender
{
    [self.textField resignFirstResponder];
    [self.delegate didComposeWithText:self.textField.text data:self.media mediaExtension:self.mediaExtension mediaURL:self.mediaURL];
    [self.mediaButton setImage:[UIImage imageNamed:@"MessageCamera"] forState:UIControlStateNormal];
    self.textField.text = nil;
    self.mediaExtension = nil;
    self.media = nil;
    self.mediaURL = nil;
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


//- (IBAction)stickerButtonAction:(id)sender
//{
//
//    if(![VObjectManager sharedManager].mainUser)
//    {
//        [self presentViewController:[VSimpleLoginViewController sharedLoginViewController] animated:YES completion:NULL];
//        return;
//    }
//    [self.textField resignFirstResponder];
//
//    self.stickersView.dataSource = self;
//    self.stickersView.delegate = self;
//
//    //  Post UICollectionView populated with stickers
//}
//
//#pragma mark - UICollectionViewDataSource
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.stickers.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"stickerCell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
//    return cell;
//}
//
////- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
////- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
//
//#pragma mark - UICollectionViewDelegate
//
////- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
////- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
////- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
////- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
////- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//
////- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
////
////- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
////- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
////
////- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
////- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
////- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
////
////- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout;
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(100.0, 100.0);
//}
//
//// 3
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}

@end
