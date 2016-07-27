//
//  VWebBrowserLayout.h
//  victorious
//
//  Created by Patrick Lynch on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 Values that determine how contents of a web browser header will be aligned,
 specifically the page title in relation to the utility buttons on either side.
 */
typedef NS_ENUM( NSInteger, VWebBrowserHeaderContentAlignment )
{
    VWebBrowserHeaderContentAlignmentLeft,
    VWebBrowserHeaderContentAlignmentCenter,
};

/**
 Values that determine where on a web browser's header the progress bar will be
 vertically aligned, either -Top or -Bottom.
 */
typedef NS_ENUM( NSInteger, VWebBrowserHeaderProgressBarAlignment )
{
    VWebBrowserHeaderProgressBarAlignmentTop,
    VWebBrowserHeaderProgressBarAlignmentBottom,
};
