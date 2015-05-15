//
//  VURLDetector.h
//  victorious
//
//  Created by Patrick Lynch on 5/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VURLDetector : NSObject

/**
 Returns an array of NSRanges that indicate where in the provided string
 a URL has been detected.
 */
- (nonnull NSArray *)detectFromString:(nonnull NSString *)string;

@end
