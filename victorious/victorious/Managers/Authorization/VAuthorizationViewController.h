//
//  VAuthorizationViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAuthorizationViewController <NSObject>
@required

- (void)setAuthorizationCompletionAction:(void(^)())authorizationCompletionAction;

@end