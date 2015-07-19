//
//  VInStreamMediaLinkType.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VInStreamMediaLinkType.h"

@class VAsset;

@interface VInStreamMediaLinkTypeHelper : NSObject

+ (VInStreamMediaLinkType)linkTypeForAsset:(VAsset *)asset andMediaCategory:(NSString *)mediaCategory;

+ (BOOL)isImageCategory:(NSString *)category;

+ (BOOL)isVideoCategory:(NSString *)category;

+ (BOOL)isGifVideoAsset:(VAsset *)asset;

@end
