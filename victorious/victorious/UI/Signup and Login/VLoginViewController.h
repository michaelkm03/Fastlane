//
//  VLoginViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAuthorizationViewController.h"

typedef NS_ENUM(NSUInteger, VLoginType)
{
    kVLoginTypeNone,
    kVLoginTypeEmail,
    kVLoginTypeFaceBook,
    kVLoginTypeTwitter,
};

@interface VLoginViewController : UIViewController <VAuthorizationViewController>

@property (nonatomic, strong) void (^authorizationCompletionAction)();

+ (VLoginViewController *)loginViewController;

@end
