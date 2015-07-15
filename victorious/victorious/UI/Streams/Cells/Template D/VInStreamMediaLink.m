//
//  VInStreamMediaLink.m
//  victorious
//
//  Created by Sharif Ahmed on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamMediaLink.h"

@implementation VInStreamMediaLink

+ (instancetype)newWithTintColor:(UIColor *)tintColor
                            font:(UIFont *)font
                       mediaType:(NSString *)mediaType
                       urlString:(NSString *)urlString
{
    __block NSString *linkLabelText;
    __block UIImage *linkIcon;
    
    [VInStreamMediaLink imageAndTextForMediaCategoryString:mediaType
                                             callbackBlock:^(UIImage *icon, NSString *text)
     {
         linkIcon = icon;
         linkLabelText = text;
     }];
    
    return [[VInStreamMediaLink alloc] initWithTintColor:tintColor
                                                    font:font
                                                    text:linkLabelText
                                                    icon:linkIcon
                                               urlString:urlString];
}

- (instancetype)initWithTintColor:(UIColor *)tintColor
                             font:(UIFont *)font
                             text:(NSString *)text
                             icon:(UIImage *)icon
                        urlString:(NSString *)urlString
{
    self = [super init];
    if ( self != nil )
    {
        _tintColor = tintColor;
        _font = font;
        _text = text;
        _icon = icon;
        _urlString = urlString;
    }
    return self;
}

+ (void)imageAndTextForMediaCategoryString:(NSString *)category callbackBlock:(void (^)(UIImage *, NSString *))callbackBlock
{
    if ( category.length > 0 )
    {
        callbackBlock([UIImage imageNamed:@"follow_user_icon"], @"whooooopie");
    }
    else
    {
        callbackBlock(nil, nil);
    }
}

- (BOOL)isEqual:(id)object
{
    if ( object == nil )
    {
        return NO;
    }
    
    if ( ![object isKindOfClass:[self class]] )
    {
        return NO;
    }
    
    return [self isEqualToInStreamMediaLink:object];
}

- (BOOL)isEqualToInStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
{
    return [self.urlString isEqualToString:inStreamMediaLink.urlString];
}

- (NSUInteger)hash
{
    return [self.urlString hash];
}

@end
