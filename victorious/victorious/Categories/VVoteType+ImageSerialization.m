//
//  VVoteType+ImageSerialization.m
//  victorious
//
//  Created by Patrick Lynch on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType+ImageSerialization.h"
#import "VTracking+RestKit.h"

NSString * const VVoteTypeImageIndexReplacementMacro = @"XXXXX";

@implementation VVoteType (ImageSerialization)

- (BOOL)containsRequiredData
{
    return  self.canCreateImages &&
            self.name != nil &&
            self.name.length > 0 &&
            self.iconImage != nil &&
            self.iconImage.length != 0;
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
    
#if DEBUG
#warning This is only until the backend is updated
    formatter.maximumIntegerDigits = formatter.minimumIntegerDigits = 2;
#endif
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    for ( NSUInteger i = 0; i < self.imageCount.unsignedIntegerValue; i++ )
    {
        NSString *numberString = [formatter stringFromNumber:@(i)];
        NSString *imageUrl = [self.imageFormat stringByReplacingOccurrencesOfString:VVoteTypeImageIndexReplacementMacro withString:numberString];
        [output addObject:imageUrl];
    }
    
    return [NSArray arrayWithArray:output];
}

@end
