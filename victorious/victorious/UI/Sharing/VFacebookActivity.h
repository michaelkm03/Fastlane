//
//  VFacebookActivity.h
//  victorious
//
//  Created by Will Long on 7/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import FBSDKShareKit;

@interface VFacebookActivity : UIActivity

/**
 The mode to use when creating a Facebook share dialog.
 Default is FBSDKShareDialogModeAutomatic
 */
@property (nonatomic) FBSDKShareDialogMode shareMode;

@end
