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
extern NSString * const VStreamCellActionViewRemixIconKey; ///< Key for "remix" icon
extern NSString * const VStreamCellActionViewRepostIconKey; ///< Key for "repost" icon
extern NSString * const VStreamCellActionViewRepostSuccessIconKey; ///< Key for "repost success" icon
extern NSString * const VStreamCellActionViewMoreIconKey; ///< Key for "more" icon

@interface VStreamCellActionView : UIView <VSequenceActionsSender>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (UIButton *)addButtonWithImage:(UIImage *)image;
- (UIButton *)addButtonWithImageKey:(NSString *)imageKey;

@property (nonatomic, weak) id<VSequenceActionsDelegate> sequenceActionsDelegate;

- (void)clearButtons;
- (void)updateLayoutOfButtons;
- (void)addShareButton;
- (void)addRemixButton;
- (void)addRepostButton;
- (void)addMoreButton;

+ (NSDictionary *)buttonImages;

@property (nonatomic, readonly) NSMutableArray *actionButtons;

@end
