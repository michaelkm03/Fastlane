//
//  VNotLoggedInProfileCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VHasManagedDependencies.h"

@class VDependencyManager, VNotAuthorizedProfileCollectionViewCell;

/**
 *  A delegate to inform about login requests.
 */
@protocol VNotAuthorizedProfileCollectionViewCellDelegate <NSObject>

/**
 *  Informs the receiver that the user would like to login.
 */
- (void)notAuthorizedProfileCellWantsLogin:(VNotAuthorizedProfileCollectionViewCell *)cell;

@end

/**
 *  A VNotAuthorizedProfileCollectionViewCell infroms the user
 *  that they are not currently logged in and provides a call
 *  to action button for them to do so.
 */
@interface VNotAuthorizedProfileCollectionViewCell : VBaseCollectionViewCell <VHasManagedDependencies>

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds andDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  A delegate conforming to VNotAuthorizedProfileCollectionViewCellDelegate.
 */
@property (nonatomic, weak) id <VNotAuthorizedProfileCollectionViewCellDelegate> delegate;

@end
