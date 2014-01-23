//
//  VUnreadConversation+RestKit.h
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUnreadConversation.h"
#import "NSManagedObject+RestKit.h"

@interface VUnreadConversation (RestKit)

+ (RKResponseDescriptor*)descriptor;

@end
