//
//  UIImageView+CrossFading.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCrossFadingView.h"

@interface VCrossFadingImageView : UIView <VCrossFadingView>

- (void)setCrossFadingImageWithURLs:(NSArray *)imageURLs tintColor:(UIColor *)tintColor andPlaceholderImage:(UIImage *)placeholderImage;

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) NSArray *imageURLs;

@end
