//
//  VEndCardModel.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@interface VEndCardModel : NSObject

@property (nonatomic, strong) NSString *videoAuthorName;
@property (nonatomic, strong) NSURL *videoAuthorProfileImageURL;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, strong) NSString *nextVideoTitle;
@property (nonatomic, strong) NSURL *nextVideoThumbailImageURL;
@property (nonatomic, strong) UIColor *bannerBackgroundColor;
@property (nonatomic, assign) NSUInteger countdownDuration;

@end
