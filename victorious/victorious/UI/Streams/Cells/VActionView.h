//
//  VActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequenceActionsDelegate.h"

@class VSequence;
@class VDependencyManager;

@protocol VActionView <NSObject>

@property (nonatomic, weak) VSequence *sequence;

@property (nonatomic, weak) id <VSequenceActionsDelegate> sequenceActionsDelegate;

@end
