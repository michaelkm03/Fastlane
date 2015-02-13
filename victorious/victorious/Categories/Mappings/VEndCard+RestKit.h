//
//  VEndCard+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 1/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard.h"

@interface VEndCard (RestKit)

+ (NSString *)entityName;

+ (RKEntityMapping *)entityMapping;

@end
