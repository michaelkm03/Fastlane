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

- (void)snapshotViewControllerWantsSnapshot:(VSnapshotViewController *)snapshotViewController;

@end

@interface VSnapshotViewController : UIViewController

@property (nonatomic, assign) BOOL buttonEnabled;

@property (nonatomic, weak) id <VSnapshotViewControllerDelegate> delegate;

@end
