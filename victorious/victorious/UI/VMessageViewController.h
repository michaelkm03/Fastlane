//
//  VMessageViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

@interface VMessageViewController : UITableViewController

@property (nonatomic, strong) VUser *otherUser;

/**
 If YES, the receiver will refresh from the server on -viewWillAppear.
 Resets back to NO on every appearance.
 */
@property (nonatomic) BOOL shouldRefreshOnAppearance;

@end
