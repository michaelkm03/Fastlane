//
//  VPassthroughContainerViewDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VCoachmarkPassthroughContainerView;

/**
    A simple delegate for recieving touch messages from the passthrough view.
 */
@protocol VCoachmarkPassthroughContainerViewDelegate <NSObject>

/**
    This method is called when the provided Coachmark
    Passthrough Container View recieves a touch.
 */
@required
- (void)passthroughViewRecievedTouch:(VCoachmarkPassthroughContainerView *)passthroughContainerView;

@end
