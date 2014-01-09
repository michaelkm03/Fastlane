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

@protocol VCreateViewControllerDelegate;

@interface VCreateViewController : UIViewController

- (instancetype)initWithType:(VCreateViewControllerType)type andDelegate:(id<VCreateViewControllerDelegate>)delegate;

@end

@protocol VCreateViewControllerDelegate <NSObject>

- (void)createViewController:(VCreateViewController *)viewController
       shouldPostWithMessage:(NSString *)message data:(NSData *)data
                   mediaType:(NSString *)mediaType;

@end
