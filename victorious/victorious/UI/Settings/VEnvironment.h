//
//  VEnvironment.h
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A VEnvironment object represents a server environment, like Dev, QA or Production.
 */
@interface VEnvironment : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL    *baseURL;
@property (nonatomic, readonly) NSNumber *appID;

- (instancetype)initWithName:(NSString *)name baseURL:(NSURL *)baseURL appID:(NSNumber *)appID NS_DESIGNATED_INITIALIZER;

/**
 Initializes a VEnvironment object with the name, baseURL, and appID read from a dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
