//
//  VVoteType.h
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>

extern NSString * const VDependencyManagerVoteTypesKey; ///< The key for retrieving vote types from an instance of VDependencyManager

@interface VVoteType : NSObject <VHasManagedDependencies>

@property (nonatomic, readonly) NSNumber *displayOrder;
@property (nonatomic, readonly) NSString *voteTypeName;
@property (nonatomic, readonly) NSString *voteTypeID;
@property (nonatomic, readonly) NSString *iconImage;
@property (nonatomic, readonly) NSString *iconImageLarge;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSNumber *flightDuration;
@property (nonatomic, readonly) NSNumber *animationDuration;
@property (nonatomic, readonly) NSNumber *isPaid;
@property (nonatomic, readonly) NSString *imageContentMode;
@property (nonatomic, readonly) NSString *productIdentifier;
@property (nonatomic, readonly) NSNumber *scaleFactor;
@property (nonatomic, readonly) NSArray *trackingURLs;

@property (nonatomic, readonly) UIViewContentMode contentMode;
@property (nonatomic, readonly) BOOL containsRequiredData;
@property (nonatomic, readonly) BOOL mustBePurchased;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Objects of type VVoteType may have a string value assigned to their `productIdentifier`
 property that indicates that corresponds to a product for sale as an In-App Purchase configured
 in iTunesConnect.  This method returns an NSSet of product identifiers from any objects in the
 `voteTypes' parameter.  Returns nil if those none of the VVoteType's supplied are purchaseable.
 */
+ (NSSet *)productIdentifiersFromVoteTypes:(NSArray *)voteTypes;

@end

#pragma mark -

@interface VDependencyManager (VVoteType)

/**
 Returns an array of VVoteType objects
 */
- (NSArray *)voteTypes;

/**
 Returns the VVoteType whose productIdentifier matches the one given.
 */
- (VVoteType *)voteTypeWithProductIdentifier:(NSString *)productIdentifier;

@end