//
//  VStreamItem+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem+Fetcher.h"

@implementation VStreamItem (Fetcher)

- (NSString *)previewImagePath
{
    NSString* previewImage;
    if ([self.previewImagesObject isKindOfClass:[NSString class]])
    {
        previewImage = self.previewImagesObject;
    }
    else if ([self.previewImagesObject isKindOfClass:[NSArray class]])
    {
        previewImage = [self.previewImagesObject firstItem];
    }
    else if (self.previewImagesObject)//if its not nil its undefined
    {
        NSAssert(false, @"undefined type for sequence.previewImage");
    }
    
    return previewImage;
}

- (NSArray *)previewImagePaths
{
    if ([self.previewImagesObject isKindOfClass:[NSArray class]] || !self.previewImagesObject)
    {
        return self.previewImagesObject;
    }
    else
    {
        return @[self.previewImagesObject];
    }
}

@end
