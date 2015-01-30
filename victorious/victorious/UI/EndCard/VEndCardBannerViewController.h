//
//  VEndCardBannerViewController.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VCountdownViewController.h"

@class VEndCardModel;

@protocol VEndCardBannerViewController <NSObject>

- (void)nextVideoSelected;

@end

@interface VEndCardBannerViewController : UIViewController

@property (nonatomic, weak) id<VEndCardBannerViewController> delegate;

- (void)configureWithModel:(VEndCardModel *)model;

- (void)startCountdownWithDuration:(NSUInteger)duration;

- (void)resetNextVideoDetails;

- (void)showNextVideoDetails;

- (void)stopCountdown;

@end
