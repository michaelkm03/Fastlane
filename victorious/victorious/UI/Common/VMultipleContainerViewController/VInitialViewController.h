//
//  VInitialViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    DO NOT ADD ANYTHING TO OR USE THIS CLASS, it's a bandaid until we rewrite our
        VMultipleContainerViewController implementation to properly cause
        viewWillAppear to fire on it's child view controllers.
 */
@protocol VInitialViewController <NSObject>

- (void)setIsInitialViewController:(BOOL)isInitialViewController;

@end
