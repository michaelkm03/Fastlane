//
//  VCreateSheetViewController.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

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

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 Block to call when user chooses an item
 */
@property (nonatomic, copy) void (^completionHandler)(VCreateSheetViewController *createSheetViewController, VCreateSheetItemIdentifier chosenItemIdentifier);

@end
