//
//  VGIFSearchResult+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFSearchResult.h"

@interface VGIFSearchResult (RestKit)

+ (NSString *)entityName;

+ (RKEntityMapping *)entityMapping;

+ (NSArray *)descriptors;

@end
