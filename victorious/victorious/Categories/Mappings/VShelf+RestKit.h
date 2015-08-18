//
//  VShelf+RestKit.h
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShelf.h"

@interface VShelf (RestKit)

+ (RKObjectMapping *)mappingForItemType:(NSString *)subType;

+ (RKEntityMapping *)mappingBaseForEntityWithName:(NSString *)entityName;

@end
