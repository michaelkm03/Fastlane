//
//  VStreamCollectionCell.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"
#import "VSequenceActionsDelegate.h"
#import "VBaseCollectionViewCell.h"

@class VSequence, VStreamCellHeaderView, VStreamCollectionCell;

@interface VStreamCollectionCell : VBaseCollectionViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, weak) IBOutlet UIImageView            *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *lowerGradientView;
@property (nonatomic, weak) IBOutlet UIView                 *overlayView;
@property (nonatomic, weak) IBOutlet UIView                 *shadeView;
@property (nonatomic, weak) IBOutlet VStreamCellHeaderView  *streamCellHeaderView;

@property (nonatomic, weak) VSequence                       *sequence;

@property (nonatomic, weak) id<VSequenceActionsDelegate> delegate;

@property (nonatomic, weak) UIViewController *parentViewController;

- (void)hideOverlays;
- (void)showOverlays;
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence;

- (void)playVideo;
- (void)pauseVideo;

@end
