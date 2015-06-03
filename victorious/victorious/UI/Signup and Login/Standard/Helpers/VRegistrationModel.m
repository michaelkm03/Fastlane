//
//  VRegistrationModel.m
//  victorious
//
//  Created by Michael Sena on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRegistrationModel.h"
#import "VUser.h"

@implementation VRegistrationModel

+ (VRegistrationModel *)registrationModelWithUser:(VUser *)user
{
    VRegistrationModel *registrationModel = [[self alloc] init];
    
    registrationModel.email = user.email;
    registrationModel.username = user.name;
    registrationModel.locationText = user.location;
    registrationModel.profileImageURL = [NSURL URLWithString:user.pictureUrl];
    
    return registrationModel;
}

@end
