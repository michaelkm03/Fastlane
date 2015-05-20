//
//  VPollView.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VPollAnswer)
{
    VPollAnswerA,
    VPollAnswerB,
};

/**
 *  VPollView show two images side by side to represent the 
 *  options of a poll. The pollIcon is centered above the image 
 *  views for each options.
 */
@interface VPollView : UIView

/**
 *  Sets the url to the appropriate internal imageView.
 */
- (void)setImageURL:(NSURL *)imageURL
      forPollAnswer:(VPollAnswer)pollAnswer;

/**
 *  The poll icon to use. Defaults to nil.
 */
@property (nonatomic, strong) IBInspectable UIImage *pollIcon;

@end
