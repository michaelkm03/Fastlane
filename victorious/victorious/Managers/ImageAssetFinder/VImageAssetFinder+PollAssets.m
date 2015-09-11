//
//  VImageAssetFinder+PollAssets.m
//  victorious
//
//  Created by Patrick Lynch on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetFinder+PollAssets.h"
#import "VAsset.h"
#import "VNode.h"

@implementation VImageAssetFinder (PollAssets)

- (VAnswer *)answerAFromAssets:(NSSet *)assets
{
    VAnswer *answer = nil;
    for (id object in assets)
    {
        if ([object isKindOfClass:[VAsset class]])
        {
            VAsset *asset = (VAsset *) object;
            if (asset.node.interactions.array.count > 0)
            {
                answer = [asset.node.interactions.array firstObject];
            }
        }
    }
    
    return answer;
}

- (VAnswer *)answerBFromAssets:(NSSet *)assets
{
    VAnswer *answer = nil;
    for (id object in assets)
    {
        if ([object isKindOfClass:[VAsset class]])
        {
            VAsset *asset = (VAsset *) object;
            if (asset.node.interactions.array.count > 1)
            {
                answer = asset.node.interactions.array[1];
            }
        }
    }
    
    return answer;
}

@end
