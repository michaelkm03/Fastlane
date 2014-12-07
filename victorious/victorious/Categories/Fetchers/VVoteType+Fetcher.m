//
//  VVoteType+Fetcher.m
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType+Fetcher.h"
#import "VVoteType+RestKit.h"
#import "VTracking+RestKit.h"

NSString * const VVoteTypeImageIndexReplacementMacro = @"XXXXX";

@implementation VVoteType (Fetcher)

+ (NSArray *)productIdentifiersFromVoteTypes:(NSArray *)voteTypes
{
    NSMutableArray *productIdentifiers = [[NSMutableArray alloc] init];
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
    {
        if ( voteType.isPaid && voteType.productIdentifier != nil )
        {
            [productIdentifiers addObject:voteType.productIdentifier];
        }
    }];
    return [NSArray arrayWithArray:productIdentifiers];
}

- (BOOL)containsRequiredData
{
    BOOL isNonPaidAndValid = self.canCreateImages && self.name != nil && self.name.length > 0 && self.iconImage != nil && self.iconImage.length > 0;
    BOOL isUnlockableAndValid = self.iconImageLarge != nil && self.iconImageLarge.length > 0;
    
    return isNonPaidAndValid || (isUnlockableAndValid && isNonPaidAndValid);
}

- (BOOL)mustBePurchased
{
    return self.productIdentifier != nil && self.isPaid && !self.isPurchased.boolValue;
}

- (BOOL)hasValidTrackingData
{
    if ( self.tracking == nil || self.tracking.ballisticCount == nil )
    {
        return NO;
    }
    
    return [VTracking urlsAreValid:self.tracking.ballisticCount];
}

- (BOOL)canCreateImages
{
    if ( self.imageCount == nil || self.imageCount.unsignedIntegerValue == 0 )
    {
        return NO;
    }
    
    if ( self.imageFormat == nil ||
        self.imageFormat.length == 0 ||
        [self.imageFormat rangeOfString:VVoteTypeImageIndexReplacementMacro].location == NSNotFound )
    {
        return NO;
    }
    
    return YES;
}

- (NSArray *)images
{
    if ( !self.canCreateImages )
    {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.paddingCharacter = @"0";
    formatter.paddingPosition = NSNumberFormatterPadBeforePrefix;
    formatter.maximumIntegerDigits = formatter.minimumIntegerDigits = VVoteTypeImageIndexReplacementMacro.length;
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    for ( NSUInteger i = 0; i < self.imageCount.unsignedIntegerValue; i++ )
    {
        NSString *numberString = [formatter stringFromNumber:@(i)];
        NSString *imageUrl = [self.imageFormat stringByReplacingOccurrencesOfString:VVoteTypeImageIndexReplacementMacro withString:numberString];
        [output addObject:imageUrl];
    }
    
    return [NSArray arrayWithArray:output];
}

- (UIViewContentMode)contentMode
{
    UIViewContentMode defaultValue = UIViewContentModeScaleAspectFill;
    
    if ( self.imageContentMode == nil )
    {
        return defaultValue;
    }
    else if ( [self.imageContentMode isEqualToString:@"scaleaspectfill"] )
    {
        return UIViewContentModeScaleAspectFill;
    }
    else if ( [self.imageContentMode isEqualToString:@"scaletofill"] )
    {
        return UIViewContentModeScaleToFill;
    }
    else if ( [self.imageContentMode isEqualToString:@"scaleaspectfit"] )
    {
        return UIViewContentModeScaleAspectFit;
    }
    else if ( [self.imageContentMode isEqualToString:@"scaleaspectfill"] )
    {
        return UIViewContentModeScaleAspectFill;
    }
    else if ( [self.imageContentMode isEqualToString:@"redraw"] )
    {
        return UIViewContentModeRedraw;
    }
    else if ( [self.imageContentMode isEqualToString:@"center"] )
    {
        return UIViewContentModeCenter;
    }
    else if ( [self.imageContentMode isEqualToString:@"top"] )
    {
        return UIViewContentModeTop;
    }
    else if ( [self.imageContentMode isEqualToString:@"bottom"] )
    {
        return UIViewContentModeBottom;
    }
    else if ( [self.imageContentMode isEqualToString:@"left"] )
    {
        return UIViewContentModeLeft;
    }
    else if ( [self.imageContentMode isEqualToString:@"right"] )
    {
        return UIViewContentModeRight;
    }
    else if ( [self.imageContentMode isEqualToString:@"topleft"] )
    {
        return UIViewContentModeTopLeft;
    }
    else if ( [self.imageContentMode isEqualToString:@"topright"] )
    {
        return UIViewContentModeTopRight;
    }
    else if ( [self.imageContentMode isEqualToString:@"bottomleft"] )
    {
        return UIViewContentModeBottomLeft;
    }
    else if ( [self.imageContentMode isEqualToString:@"bottomright"] )
    {
        return UIViewContentModeBottomRight;
    }
    
    return UIViewContentModeScaleAspectFill;
}

@end
