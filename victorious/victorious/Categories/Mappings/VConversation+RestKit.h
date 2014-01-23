//
//  VConversation+RestKit.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation.h"
#import "NSManagedObject+RestKit.h"

@interface VConversation (RestKit)

+ (RKResponseDescriptor*)descriptor;

@end
