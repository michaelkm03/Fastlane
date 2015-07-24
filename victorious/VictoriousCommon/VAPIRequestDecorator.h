//
//  VAPIRequestDecorator.h
//  victorious
//
//  Created by Josh Hinman on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/**
 Contains methods for modifying NSMutableURLRequest objects prior to sending API requests to the Victorious back-end.
 */
@interface VAPIRequestDecorator : NSObject

@property (nonatomic, copy) NSString *deviceID; ///< Get this from UIDevice.identifierForVendor
@property (nonatomic, strong) NSNumber *appID; ///< The app ID from the current server environment
@property (nonatomic, copy) NSString *buildNumber; ///< Current build number
@property (nonatomic, copy) NSString *versionNumber; ///< Current version number
@property (nonatomic, copy) NSString *sessionID; ///< Unique identifier for this session, if available
@property (nonatomic, copy) NSString *locale; ///< Preferred locale
@property (nonatomic, strong) NSNumber *userID; ///< currently-logged-in user, or nil if no user is logged in.
@property (nonatomic, copy) NSString *token; ///< Auth token, if available.
@property (nonatomic, copy) NSString *experimentIDs; ///< Comma-separated list of active experiment IDs.
@property (nonatomic) CLLocationCoordinate2D location; ///< User's location, if available
@property (nonatomic, copy) NSString *postalCode; ///< User's postal code, if available

/**
 Adds HTTP headers necessary for communicating with the Victorious API
 */
- (void)updateHeadersInRequest:(NSMutableURLRequest *)request;

@end
