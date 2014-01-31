//
//  VProfileViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

typedef NS_ENUM(NSInteger, VProfileUserID)
{
    kProfileUserIDSelf  =   -1
};

@interface VProfileViewController : UIViewController

+ (instancetype)profileWithSelf;
+ (instancetype)profileWithUser:(VProfileUserID)aUserID;

@end
