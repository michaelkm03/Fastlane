//
//  VSequenceActionControllerDelegate.h
//  victorious
//
//  Created by Vincent Ho on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#ifndef SequenceActionControllerDelegate_h
#define SequenceActionControllerDelegate_h

@protocol VSequenceActionControllerDelegate <NSObject>
@optional

- (void)sequenceActionControllerDidDeleteContent;
- (void)sequenceActionControllerDidFlagContent;
- (void)sequenceActionControllerDidBlockUser;

@end

#endif /* VSequenceActionControllerDelegate_h */
