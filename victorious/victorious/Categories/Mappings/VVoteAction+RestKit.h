//
//  VVoteAction+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteAction.h"
#import "NSManagedObject+RestKit.h"

@interface VVoteAction (RestKit)

+ (RKResponseDescriptor *)descriptor;

@end
