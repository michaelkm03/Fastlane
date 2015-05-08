//
//  VWebBrowserHeaderLayoutManager.h
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VWebBrowserLayout.h"

@class VWebBrowserHeaderViewController;

@interface VWebBrowserHeaderLayoutManager : NSObject

@property (nonatomic, assign) VWebBrowserHeaderProgressBarAlignment progressBarAlignment;
@property (nonatomic, assign) VWebBrowserHeaderContentAlignment contentAlignment;
@property (nonatomic, weak) IBOutlet VWebBrowserHeaderViewController *header;

@property (nonatomic, weak) id<VWebBrowserHeaderStateDataSource> stateDataSource;

- (void)update;

- (void)updateAnimated:(BOOL)animated;

@end