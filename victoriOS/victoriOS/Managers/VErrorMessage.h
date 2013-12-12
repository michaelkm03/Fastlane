//
//  VErrorMessage.h
//  victoriOS
//
//  Created by Will Long on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

@interface VErrorMessage : NSObject

@property (nonatomic, assign) NSInteger error;
@property (nonatomic, assign) NSInteger api_version;
@property (nonatomic, assign) NSInteger app_id;
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, strong) NSString* message;

+ (RKObjectMapping *)objectMapping;

@end
