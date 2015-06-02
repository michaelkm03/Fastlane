//
//  VImageAsset+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSManagedObject+RestKit.h"
#import "VImageAsset.h"

@interface VImageAsset (RestKit)

+ (RKEntityMapping *)entityMapping;

@end
