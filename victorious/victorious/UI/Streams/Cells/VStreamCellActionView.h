//
//  VStreamCellActionView.h
//  victorious
//
//  Created by Will Long on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSequenceActionsDelegate.h"

@class VSequence;

@interface VStreamCellActionView : UIView

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, weak) id<VSequenceActionsDelegate> delegate;

- (void)clearButtons;
- (void)addShareButton;
- (void)addRemixButton;
- (void)addRepostButton;
- (void)addFlagButton;

@end
