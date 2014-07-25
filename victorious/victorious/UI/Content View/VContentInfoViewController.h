//
//  VContentInfoViewController.h
//  victorious
//
//  Created by Will Long on 7/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSequence;

#import <UIKit/UIKit.h>

@protocol VContentInfoDelegate <NSObject>

- (void)didCloseFromInfo;
- (void)willCommentFromInfo;

@end

@interface VContentInfoViewController : UIViewController

@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic, weak) IBOutlet UIView* mediaContainerView;
@property (nonatomic, weak) id<VContentInfoDelegate> delegate;

@property (strong, nonatomic) UIViewController* mediaVC;///<View controller displaying the media for the sequence. Note: can be nil if the media is only a view on content screen (e.g. any image view)

+ (VContentInfoViewController *)sharedInstance;

@end
