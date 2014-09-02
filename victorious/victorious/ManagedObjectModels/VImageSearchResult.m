//
//  VImageSearchResult.m
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageSearchResult.h"

@implementation VImageSearchResult

- (NSString *)description
{
    return self.sourceURL.absoluteString;
}

+ (RKResponseDescriptor *)descriptor
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:@{ @"url": NSStringFromSelector(@selector(sourceURL)),
                                                   @"thumbnail": NSStringFromSelector(@selector(thumbnailURL))
                                                   }];
    return [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                        method:RKRequestMethodAny
                                                   pathPattern:@"/api/image/search/:keywords/:page/:per_page"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
