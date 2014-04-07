//
//  VImageSearchViewController.h
//  victorious
//
//  Created by Josh Hinman on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageSearchDataSource.h"

#import <UIKit/UIKit.h>

@class VImageSearchViewController;

@protocol VImageSearchViewControllerDelegate <NSObject>
@optional

- (void)imageSearchDidCancel:(VImageSearchViewController *)imageSearch;
- (void)imageSearch:(VImageSearchViewController *)imageSearch didFinishPickingImage:(UIImage *)image;

@end

@interface VImageSearchViewController : UIViewController <UICollectionViewDelegate, UITextFieldDelegate, VImageSearchDataDelegate>

@property (nonatomic, weak) id<VImageSearchViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField        *searchField;
@property (nonatomic, weak) IBOutlet UICollectionView   *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hrHeightConstraint;

+ (instancetype)newImageSearchViewController;

- (IBAction)closeButtonTapped:(id)sender;

@end
