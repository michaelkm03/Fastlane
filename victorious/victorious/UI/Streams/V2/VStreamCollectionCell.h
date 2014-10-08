//
//  VStreamCollectionCell.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence, VStreamCellHeaderView, VStreamCollectionCell;

extern NSString * const VStreamCollectionCellName;

@protocol VStreamCollectionCellDelegate <NSObject>
@required

- (void)willCommentOnSequence:(VSequence *)sequenceObject inStreamCollectionCell:(VStreamCollectionCell *)streamCollectionCell;

@end

@interface VStreamCollectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView            *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *lowerGradientView;
@property (nonatomic, weak) IBOutlet UIView                 *overlayView;
@property (nonatomic, weak) IBOutlet UIView                 *shadeView;
@property (nonatomic, weak) IBOutlet VStreamCellHeaderView  *streamCellHeaderView;

@property (nonatomic, weak) VSequence                       *sequence;

@property (nonatomic, weak) id<VStreamCollectionCellDelegate> delegate;

@property (nonatomic, weak) UIViewController *parentViewController;

- (void)hideOverlays;
- (void)showOverlays;

@end
