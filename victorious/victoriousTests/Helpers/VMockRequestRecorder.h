//
//  VMockRequestRecorder.h
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "victorious-Swift.h"

/* Defines an object that records sent requests */
@interface VMockRequestRecorder : NSObject

@property (nonatomic, strong) NSMutableArray *requestsSent;

- (void)recordRequest:(NSURLRequest *)request;

@end
