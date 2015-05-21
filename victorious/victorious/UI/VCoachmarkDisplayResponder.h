//
//  VCoachmarkDisplayResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning DOCS INCOMPLETE

typedef void (^VMenuItemDiscoveryBlock) (BOOL found, CGRect location);

@protocol VCoachmarkDisplayResponder <NSObject>

@required
- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion;

@end
