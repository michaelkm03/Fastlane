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

@interface VVoteType : NSObject <VHasManagedDependencies>

@property (nonatomic, readonly) NSNumber *displayOrder;
@property (nonatomic, readonly) NSString *voteTypeName;
@property (nonatomic, readonly) NSString *voteTypeID;
@property (nonatomic, readonly) UIImage *iconImage;
@property (nonatomic, readonly) UIImage *iconImageLarge;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSNumber *flightDuration;
@property (nonatomic, readonly) NSNumber *animationDuration;
@property (nonatomic, readonly) NSNumber *cooldownDuration;
@property (nonatomic, readonly) NSNumber *isPaid;
@property (nonatomic, readonly) NSString *imageContentMode;
@property (nonatomic, readonly) NSString *productIdentifier;
@property (nonatomic, readonly) NSArray *trackingURLs;
@property (nonatomic, readonly) NSNumber *unlockLevel;

@property (nonatomic, readonly) UIViewContentMode contentMode;
@property (nonatomic, readonly) BOOL containsRequiredData;
@property (nonatomic, readonly) BOOL mustBePurchased;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end
