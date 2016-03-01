//
//  VSequenceActionControllerDelegate.h
//  victorious
//
//  Created by Vincent Ho on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@class VUser, VSequence;

@protocol VSequenceActionControllerDelegate <NSObject>
@optional

- (void)sequenceActionControllerDidDeleteSequence:(VSequence *)sequence;

- (void)sequenceActionControllerDidFlagSequence:(VSequence *)sequence;

- (void)sequenceActionControllerDidBlockUser:(VUser *)user;

@end
