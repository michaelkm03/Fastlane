//
//  VSequenceActionResponder.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequenceActionController;

@protocol VSequenceActionResponder <NSObject>

@property (strong, nonatomic, readonly) VSequenceActionController *sequenceActionController;

@end
