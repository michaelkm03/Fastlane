//
//  VPollView.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VPollView show two images side by side to represent the 
 *  options of a poll. The pollIcon is centered above the image 
 *  views for each options.
 */
@interface VPollView : UIView

@property (nonatomic, strong) IBInspectable UIImage *pollIcon;
@property (nonatomic, strong) UIImageView *answerAImageView;
@property (nonatomic, strong) UIImageView *answerBImageView;
@property (nonatomic, strong) UIButton *playButtonA;
@property (nonatomic, strong) UIButton *playButtonB;

- (void)setPollIconHidden:(BOOL)hidden animated:(BOOL)animated;

@end
