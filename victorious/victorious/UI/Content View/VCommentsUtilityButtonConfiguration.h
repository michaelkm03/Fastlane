//
//  VCommentsUtilityButtonConfiguration.h
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

@interface VUtilityButtonConfig : NSObject

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface VCommentsUtilityButtonConfiguration : NSObject

+ (VCommentsUtilityButtonConfiguration *)sharedInstance;

@property (nonatomic, strong) VUtilityButtonConfig *editButtonConfig;
@property (nonatomic, strong) VUtilityButtonConfig *deleteButtonConfig;
@property (nonatomic, strong) VUtilityButtonConfig *flagButtonConfig;

@end