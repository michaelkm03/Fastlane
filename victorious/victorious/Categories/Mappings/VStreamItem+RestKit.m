//
//  VStreamItem+RestKit.m
//  victorious
//
//  Created by Sharif Ahmed on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItem+RestKit.h"

@implementation VStreamItem (RestKit)

+ (NSArray *)mappingIdentificationAttributes
{
    //Identification attributes are AND-ed (see RKFetchRequestManagedObjectCache.m line 58)
    return @[ VSelectorName(remoteId), VSelectorName(headline) ];
}

@end
