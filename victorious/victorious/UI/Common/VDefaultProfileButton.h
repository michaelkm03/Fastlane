//
//  VDefaultProfileButton.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser;

@interface VDefaultProfileButton : UIButton

@property (nonatomic, strong) VUser *user;

- (void)setImageWithUser:(VUser *)user;

@end
