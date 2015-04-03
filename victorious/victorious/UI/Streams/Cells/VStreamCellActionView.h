//
//  VStreamCellActionView.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSequenceActionsSender.h"

@class VSequence, VDependencyManager;

extern CGFloat const VStreamCellActionViewActionButtonBuffer;

//Use or override the string values that are keyed by these keys in the button images dictionary to affect images displayed in actionView
extern NSString * const VStreamCellActionViewShareIconKey; ///< Key for "share" icon
extern NSString * const VStreamCellActionViewGifIconKey; ///< Key for "remix" icon
extern NSString * const VStreamCellActionViewMemeIconKey; ///< Key for "more" icon
extern NSString * const VStreamCellActionViewRepostIconKey; ///< Key for "repost" icon
extern NSString * const VStreamCellActionViewRepostSuccessIconKey; ///< Key for "repost success" icon

@interface VStreamCellActionView : UIView <VSequenceActionsSender>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (UIButton *)addButtonWithImage:(UIImage *)image;
- (UIButton *)addButtonWithImageKey:(NSString *)imageKey;

@property (nonatomic, weak) id<VSequenceActionsDelegate> sequenceActionsDelegate;

- (void)clearButtons;
- (void)updateLayoutOfButtons;
- (void)addShareButton;
- (void)addGifButton;
- (void)addMemeButton;
- (void)addRepostButton;

+ (NSDictionary *)buttonImages;

@property (nonatomic, readonly) NSMutableArray *actionButtons;

@end
