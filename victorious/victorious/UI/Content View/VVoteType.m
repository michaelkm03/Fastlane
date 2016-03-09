//
//  VVoteType.m
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VDependencyManager+VTracking.h"
#import "VVoteType.h"
#import "victorious-Swift.h"

static NSString * const kImageURLKey = @"imageURL";

@interface VVoteType ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VVoteType

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (NSNumber *)displayOrder
{
    return [self.dependencyManager numberForKey:@"displayOrder"];
}

- (NSString *)voteTypeName
{
    return [self.dependencyManager stringForKey:@"voteTypeName"];
}

- (NSString *)voteTypeID
{
    return [self.dependencyManager stringForKey:@"voteTypeID"];
}

- (UIImage *)iconImage
{
    return [self.dependencyManager imageForKey:@"icon"];
}

- (UIImage *)iconImageLarge
{
    return [self.dependencyManager imageForKey:@"iconLarge"];
}

- (NSArray *)images
{
    return [self.dependencyManager arrayOfImagesForKey:@"images"];
}

- (NSNumber *)flightDuration
{
    return [self.dependencyManager numberForKey:@"flightDuration"];
}

- (NSNumber *)animationDuration
{
    return [self.dependencyManager numberForKey:@"animationDuration"];
}

- (NSNumber *)cooldownDuration
{
    return [self.dependencyManager numberForKey:@"cooldownDuration"];
}

- (NSNumber *)isPaid
{
    return [self.dependencyManager numberForKey:@"isPaid"];
}

- (NSString *)productIdentifier
{
    return [self.dependencyManager stringForKey:@"appleProductID"];
}

- (NSArray *)trackingURLs
{
    return [self.dependencyManager trackingURLsForKey:VTrackingBallisticCountKey];
}

- (NSNumber *)unlockLevel
{
    return [self.dependencyManager numberForKey:@"fanloyaltyLevel"];
}

+ (NSSet *)productIdentifiersFromVoteTypes:(NSArray *)voteTypes
{
    NSMutableSet *productIdentifiers = [[NSMutableSet alloc] init];
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         if ( voteType.isPaid && voteType.productIdentifier != nil )
         {
             [productIdentifiers addObject:voteType.productIdentifier];
         }
     }];
    return [NSSet setWithSet:productIdentifiers];
}

- (BOOL)containsRequiredData
{
    BOOL hasValidImages = [self.dependencyManager hasArrayOfImagesForKey:@"images"];
    BOOL isNonPaidAndValid = hasValidImages && self.voteTypeName.length > 0 && self.iconImage != nil;
    BOOL isUnlockableAndValid = self.iconImageLarge != nil;
    
    return isNonPaidAndValid || (isUnlockableAndValid && isNonPaidAndValid);
}

- (BOOL)mustBePurchased
{
    return self.productIdentifier != nil && self.isPaid;
}

- (UIViewContentMode)contentMode
{
    NSString *viewContentMode = [self.dependencyManager stringForKey:@"viewContentMode"];
    
    if ( [viewContentMode isEqualToString:@"scaleaspectfill"] )
    {
        return UIViewContentModeScaleAspectFill;
    }
    else if ( [viewContentMode isEqualToString:@"scaletofill"] )
    {
        return UIViewContentModeScaleToFill;
    }
    else if ( [viewContentMode isEqualToString:@"scaleaspectfit"] )
    {
        return UIViewContentModeScaleAspectFit;
    }
    else if ( [viewContentMode isEqualToString:@"scaleaspectfill"] )
    {
        return UIViewContentModeScaleAspectFill;
    }
    else if ( [viewContentMode isEqualToString:@"redraw"] )
    {
        return UIViewContentModeRedraw;
    }
    else if ( [viewContentMode isEqualToString:@"center"] )
    {
        return UIViewContentModeCenter;
    }
    else if ( [viewContentMode isEqualToString:@"top"] )
    {
        return UIViewContentModeTop;
    }
    else if ( [viewContentMode isEqualToString:@"bottom"] )
    {
        return UIViewContentModeBottom;
    }
    else if ( [viewContentMode isEqualToString:@"left"] )
    {
        return UIViewContentModeLeft;
    }
    else if ( [viewContentMode isEqualToString:@"right"] )
    {
        return UIViewContentModeRight;
    }
    else if ( [viewContentMode isEqualToString:@"topleft"] )
    {
        return UIViewContentModeTopLeft;
    }
    else if ( [viewContentMode isEqualToString:@"topright"] )
    {
        return UIViewContentModeTopRight;
    }
    else if ( [viewContentMode isEqualToString:@"bottomleft"] )
    {
        return UIViewContentModeBottomLeft;
    }
    else if ( [viewContentMode isEqualToString:@"bottomright"] )
    {
        return UIViewContentModeBottomRight;
    }
    
    return UIViewContentModeScaleAspectFill;
}

@end
