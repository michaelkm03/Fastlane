//
//  VWebBrowserHeaderState.h
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

typedef NS_ENUM( NSInteger, VWebBrowserHeaderContentAlignment )
{
    VWebBrowserHeaderContentAlignmentLeft,
    VWebBrowserHeaderContentAlignmentCenter,
};

typedef NS_ENUM( NSInteger, VWebBrowserHeaderProgressBarAlignment )
{
    VWebBrowserHeaderProgressBarAlignmentTop,
    VWebBrowserHeaderProgressBarAlignmentBottom,
};

@class VWebBrowserHeaderViewController;

@interface VWebBrowserHeaderLayoutManager : NSObject

@property (nonatomic, assign) VWebBrowserHeaderProgressBarAlignment progressBarAlignment;
@property (nonatomic, assign) VWebBrowserHeaderContentAlignment contentAlignment;

@property (nonatomic, weak) IBOutlet VWebBrowserHeaderViewController *header;

- (void)update;

- (void)updateAnimated:(BOOL)animated;

@end