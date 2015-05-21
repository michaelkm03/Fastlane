//
//  VPassthroughContainerViewDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VCoachmarkPassthroughContainerView;

#warning DOCS INCOMPLETE

@protocol VCoachmarkPassthroughContainerViewDelegate <NSObject>

@required
- (void)passthroughViewRecievedTouch:(VCoachmarkPassthroughContainerView *)passthroughContainerView;

@end
