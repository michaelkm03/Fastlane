//
//  VDefaultProfileImageView.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser;

@interface VDefaultProfileImageView : UIImageView

- (void)setImageWithUser:(VUser *)user;

@end
