//
//  VRegistrationModel.h
//  victorious
//
//  Created by Michael Sena on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

/**
 *  A simple model for passing around values related to 
 *  registration and updating the user. Should probably 
 *  be a tuple.
 */
@interface VRegistrationModel : NSObject

/**
 *  Creates a registration model for the passed in user 
 *  configured with any corresponding properties.
 */
+ (VRegistrationModel *)registrationModelWithUser:(VUser *)user;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *locationText;

@end
