//
//  VCreateSheetViewController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

static const CGFloat kShadowOffset = 3.0f;
static NSString * const kAnimateFromTopKey = @"animateFromTop";

/**
 Enum to be used when clarifying which type of workspace to open
 as a result of the user choosing one of the content creation modes.
 */
typedef NS_ENUM(NSInteger, VCreateSheetItemIdentifier)
{
    VCreateSheetItemIdentifierImage,
    VCreateSheetItemIdentifierVideo,
    VCreateSheetItemIdentifierPoll,
    VCreateSheetItemIdentifierMeme,
    VCreateSheetItemIdentifierGIF,
    VCreateSheetItemIdentifierUnknown
};

@interface VCreateSheetViewController : UIViewController <VHasManagedDependencies>

/**
 Dependency manager
 */
@property (strong, nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 Block to call when user chooses an item.
 */
@property (nonatomic, copy) void (^completionHandler)(VCreateSheetViewController *createSheetViewController, VCreateSheetItemIdentifier chosenItemIdentifier);

/**
 Collection view that displays the menu items.
 */
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 The dismiss button that appears at the bottom.
 */
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end
