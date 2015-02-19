//
//  VSnapshotViewController.h
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSnapshotViewController;

@protocol VSnapshotViewControllerDelegate <NSObject>

/**
 *  Informs a delegate that the user has tapped on a snapshot UI.
 */
- (void)snapshotViewControllerWantsSnapshot:(VSnapshotViewController *)snapshotViewController;

@end

/**
 *  A ViewController that represents the UI of a snapshot tool
 */
@interface VSnapshotViewController : UIViewController

/**
 *  Whether or not the snapshot button should be enabled.
 */
@property (nonatomic, assign) BOOL buttonEnabled;

/**
 *  A delegate to inform about the user selecting snapshots.
 */
@property (nonatomic, weak) id <VSnapshotViewControllerDelegate> delegate;

@end
