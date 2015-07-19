//
//  VInStreamMediaLink.h
//  victorious
//
//  Created by Sharif Ahmed on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VInStreamMediaLinkType.h"

@class VDependencyManager;

@interface VInStreamMediaLink : NSObject

+ (instancetype)newWithTintColor:(UIColor *)tintColor
                            font:(UIFont *)font
                       mediaType:(NSString *)mediaType
                       urlString:(NSString *)urlString
            andDependencyManager:(VDependencyManager *)dependencyManager;

- (instancetype)initWithTintColor:(UIColor *)tintColor
                             font:(UIFont *)font
                             text:(NSString *)text
                             icon:(UIImage *)icon
                         linkType:(VInStreamMediaLinkType)linkType
                        urlString:(NSString *)urlString;

@property (nonatomic, readonly) UIColor *tintColor;
@property (nonatomic, readonly) UIFont *font;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) VInStreamMediaLinkType mediaLinkType;
@property (nonatomic, readonly) NSString *urlString;

@end
