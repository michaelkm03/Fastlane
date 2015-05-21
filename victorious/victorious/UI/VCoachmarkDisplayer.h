//
//  VCoachmarkDisplayer.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning DOCS INCOMPLETE

static NSString * const VScreenIdentifierKey = @"id";

@protocol VCoachmarkDisplayer <NSObject>

@required
- (NSString *)screenIdentifier;

@optional
- (BOOL)selectorIsVisible;

@end
