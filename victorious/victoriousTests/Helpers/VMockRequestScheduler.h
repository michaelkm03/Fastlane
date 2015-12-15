//
//  VMockRequestScheduler.h
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "victorious-Swift.h"

@interface VMockRequestScheduler : NSObject

@property (nonatomic, strong) NSMutableArray *requestsScheduled;
@property (nonatomic, strong) NSMutableArray *requestsSent;

@end
