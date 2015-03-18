//
//  VStreamCollectionCell.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VSharedCollectionReusableViewMethods.h"
#import "VSequenceActionsSender.h"
#import "VBaseCollectionViewCell.h"

@class VSequence, VStreamCellHeaderView, VStreamCollectionCell, CCHLinkTextView;
/**
 This value will be used to update the lineFragmentPadding of the
 captionTextView and serve as reference in size calculations
 */
extern const CGFloat VStreamCollectionCellTextViewLineFragmentPadding;

@class CCHLinkTextView, VDependencyManager, VSequence, VStreamCellHeaderView, VStreamCollectionCell;

@interface VStreamCollectionCell : VBaseCollectionViewCell <VSequenceActionsSender, VSharedCollectionReusableViewMethods, VHasManagedDependancies>

@property (nonatomic, weak) IBOutlet UIImageView            *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *lowerGradientView;
@property (nonatomic, weak) IBOutlet UIView                 *overlayView;
@property (nonatomic, weak) IBOutlet UIView                 *shadeView;
@property (nonatomic, weak) IBOutlet VStreamCellHeaderView  *streamCellHeaderView;

@property (nonatomic, weak) IBOutlet CCHLinkTextView        *captionTextView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *captionTextViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *captionTextViewTopConstraint;
@property (nonatomic, weak) IBOutlet UILabel                *commentsLabel;

@property (nonatomic, weak) VSequence                       *sequence;

@property (nonatomic, weak) id<VSequenceActionsDelegate> sequenceActionsDelegate;

@property (nonatomic, weak) UIViewController *parentViewController;

/**
 A rectangle that corresponds to any media asset within this view,
 useful for indicating its visibility when scrolling the collection view.
 */
@property (nonatomic, assign, readonly) CGRect mediaContentFrame;

/**
 The name of the nib file for the cell's header view
 */
@property (nonatomic, readonly) NSString *headerViewNibName;

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager;

/**
 The attributes that will be used to display the comment count

 @param dependencyManager An instance of VDependencyManager used to determine which font choice
*/
+ (NSDictionary *)sequenceCommentCountAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 The attributes that will be used to display the sequence description (a.k.a. the caption)
 
 @param dependencyManager An instance of VDependencyManager used to determine which font choice
 */
+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)playVideo;
- (void)pauseVideo;

- (void)reloadCommentsCount;

- (void)setDescriptionText:(NSString *)text;

- (NSUInteger)maxCaptionLines;

@end
