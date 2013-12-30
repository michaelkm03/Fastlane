//
//  VAddActionViewController.h
//  victorious
//
//  Created by David Keegan on 12/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

@class AMBlurView;

typedef NS_ENUM(NSInteger, VAddActionViewControllerType){
    VAddActionViewControllerTypeImage,
    VAddActionViewControllerTypeVideo,
    VAddActionViewControllerTypePoll
};

@protocol VAddActionViewControllerDelegate;

@interface VAddActionViewController : UIViewController

@property (weak, nonatomic) id<VAddActionViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet AMBlurView *contentView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@protocol VAddActionViewControllerDelegate <NSObject>

- (void)addActionViewController:(VAddActionViewController *)viewController didChooseAction:(VAddActionViewControllerType)action;

@end
