//
//  VLoginViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VLoginType)
{
    kVLoginTypeNone,
    kVLoginTypeEmail,
    kVLoginTypeFaceBook,
    kVLoginTypeTwitter,
};

@interface VLoginViewController : UIViewController

+ (VLoginViewController *)loginViewController;

@end
