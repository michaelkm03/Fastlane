//
//  VImageLinkViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMediaLinkViewController.h"

/**
    A media link view controller for displaying an image.
 */
@interface VImageLinkViewController : VAbstractMediaLinkViewController

/**
 Sets the mediaUrl property and default value of the contentAspectRatio.
 
 @param url The url that media should be loaded from. Must not be nil.
 
 @return A VImageLinkViewController.
 */
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@end
