//
//  VFollowHashtagControl.h
//  victorious
//
//  Created by Lawrence Leach on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFollowHashtagControl : UIControl

@property (nonatomic, assign) BOOL subscribed;

- (void)setSubscribed:(BOOL)subscribed
             animated:(BOOL)animated;

@end
