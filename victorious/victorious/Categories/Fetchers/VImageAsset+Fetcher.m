//
//  VImageAsset+Fetcher.m
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAsset+Fetcher.h"
#import "NSData+ImageContentType.h"

@implementation VImageAsset (Fetcher)

- (CGFloat)area
{
    return self.width.floatValue * self.height.floatValue;
}

- (BOOL)fitsWithinSize:(CGSize)size
{
    return self.width.floatValue <= size.width && self.height.floatValue <= size.height;
}

- (BOOL)encompassesSize:(CGSize)size
{
    return self.width.floatValue >= size.width && self.height.floatValue >= size.height;
}

@end
