//
//  VCreationInfoContainer.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VActionBarFlexibleWidth.h"

@class VSequence;
@class VCreationInfoContainer;
@class VUser;

/**
 *  A delegate to inform a delegate about when a user is selected from
 *  the creation info container.
 */
@protocol VCreationInfoContainerDelegate <NSObject>

/**
 *  Informs the delegate about user selection.
 */
- (void)creationInfoContainer:(VCreationInfoContainer *)container
       selectedUserOnSequence:(VSequence *)sequence;

@end


/**
 *  VCreationInfoContainer is used to display information about the creator
 *  of a given sequence. Will show "remixed/giffed" by text when the content is derivative.
 *
 *  VCreationInfoContainer implements VActionBarTruncation and can safely be truncated.
 */
@interface VCreationInfoContainer : UIView <VHasManagedDependencies, VActionBarFlexibleWidth>

/**
 *  The sequence that this creation infor container view represents.
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 *  The delegate that will be informed of user selection.
 */
@property (nonatomic, weak) id <VCreationInfoContainerDelegate> delegate;

@end
