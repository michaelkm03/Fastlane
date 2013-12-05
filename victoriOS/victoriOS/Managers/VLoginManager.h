//
//  VLoginManager.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLoginManager : NSObject

+ (void)loginToFacebook;

+ (void)loginToVictoriousWithEmail:(NSString*)email andPassword:(NSString*)password;
+ (void)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name;
+ (void)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name;

@end
