//
//  VStreamCellActionView.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSequenceActionsDelegate.h"

@class VSequence, VDependencyManager;

@interface VStreamCellActionView : UIView

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, weak) id<VSequenceActionsDelegate> delegate;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (UIButton *)addButtonWithImage:(UIImage *)image;

- (void)clearButtons;
- (void)addShareButton;
- (void)addRemixButton;
- (void)addRepostButton;
- (void)addMoreButton;

@property (nonatomic, readonly) NSMutableArray *actionButtons;

@end
