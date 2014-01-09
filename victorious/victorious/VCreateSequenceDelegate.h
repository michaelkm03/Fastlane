//
//  VCreateSequenceDelegate.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@protocol VCreateSequenceDelegate <NSObject>

- (void)createViewController:(UIViewController *)viewController
       shouldPostWithMessage:(NSString *)message data:(NSData *)data
                   mediaType:(NSString *)mediaType;

@end