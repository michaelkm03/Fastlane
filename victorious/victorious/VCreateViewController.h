//
//  VCreateViewController.h
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VCreateViewControllerType){
    VCreateViewControllerTypePhoto,
    VCreateViewControllerTypeVideo,
    VCreateViewControllerTypePhotoAndVideo,
    VCreateViewControllerTypePoll,
    VCreateViewControllerTypeForum
};

@interface VCreateViewController : UIViewController

- (instancetype)initWithType:(VCreateViewControllerType)type;

@end
