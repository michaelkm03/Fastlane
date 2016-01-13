//
//  VContentViewOriginViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 10/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    Classes that conform to this protocol will have a chance to update their view(s)
    before a transition to the content view occurs.
 */
@protocol VContentViewOriginViewController <NSObject>

/**
    Called right before a transition to the content view occurs.
 */
- (void)prepareForScreenshot;

@end
