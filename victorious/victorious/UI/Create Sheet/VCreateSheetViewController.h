//
//  VCreateSheetViewController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VCreationFlowTypes.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kCreationSheetWillShow = @"v_creationSheetWillShow";
static NSString * const kCreationSheetWillHide = @"v_creationSheetWillHide";

static NSString * const kAnimateFromTopKey = @"animateFromTop";


@interface VCreateSheetViewController : UIViewController <VHasManagedDependencies>

/**
 Dependency manager
 */
@property (strong, nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 Block to call when user chooses an item.
 */
@property (nonatomic, copy) void (^completionHandler)(VCreateSheetViewController *createSheetViewController, VCreationFlowType chosenItemIdentifier);

/**
 Collection view that displays the menu items.
 */
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 The dismiss button that appears at the bottom.
 */
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

NS_ASSUME_NONNULL_END
