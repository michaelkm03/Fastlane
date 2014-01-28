//
//  VLoginWithSocialViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VSocialType)
{
    kVSocialTypeFaceBook,
    kVSocialTypeTwitter
};

@interface VProfileWithSocialViewController : UITableViewController

@property (nonatomic, assign)   VSocialType     socialType;

@end
