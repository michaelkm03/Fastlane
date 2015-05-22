//
//  VRegistrationModel.h
//  victorious
//
//  Created by Michael Sena on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRegistrationModel : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *locationText;

@end
