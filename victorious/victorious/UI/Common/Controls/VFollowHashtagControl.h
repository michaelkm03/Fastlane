//
//  VFollowHashtagControl.h
//  victorious
//
//  Created by Lawrence Leach on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowControl.h"

@interface VFollowHashtagControl : VFollowControl

- (void)setSubscribed:(BOOL)subscribed
             animated:(BOOL)animated;

@property (nonatomic, assign, getter=isSubscribed) BOOL subscribed;

@end
