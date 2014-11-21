//
//  VAlertAction.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VAlertActionStyle)
{
    VAlertActionStyleDefault,
    VAlertActionStyleDestructive,
    VAlertActionStyleCancel
};

@interface VAlertAction : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly, assign) NSInteger style;
@property (nonatomic, readonly, strong) void (^handler)(VAlertAction *);

- (instancetype)initWithTitle:(NSString *)title style:(VAlertActionStyle)style handler:(void(^)(VAlertAction *))handler;

- (void)execute;

@end