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
            andDependencyManager:(VDependencyManager *)dependencyManager
{
    __block NSString *linkLabelText;
    __block UIImage *linkIcon;
    
    VInStreamMediaLinkType linkType = [self linkTypeForCategoryString:mediaType];
    [VInStreamMediaLink imageAndTextForMediaLinkType:linkType
                                   dependencyManager:dependencyManager
                                    andCallbackBlock:^(UIImage *icon, NSString *text)
     {
         linkIcon = icon;
         linkLabelText = text;
     }];
    
    return [[VInStreamMediaLink alloc] initWithTintColor:tintColor
                                                    font:font
                                                    text:linkLabelText
                                                    icon:linkIcon
                                                linkType:linkType
                                               urlString:urlString];
}

- (instancetype)initWithTintColor:(UIColor *)tintColor
                             font:(UIFont *)font
                             text:(NSString *)text
                             icon:(UIImage *)icon
                         linkType:(VInStreamMediaLinkType)linkType
                        urlString:(NSString *)urlString
{
    self = [super init];
    if ( self != nil )
    {
        _tintColor = tintColor;
        _font = font;
        _text = text;
        _icon = icon;
        _mediaLinkType = linkType;
        _urlString = urlString;
    }
    return self;
}

+ (VInStreamMediaLinkType)linkTypeForCategoryString:(NSString *)category
{
    if ( [category isEqualToString:@"image"] )
    {
        return VInStreamMediaLinkTypeImage;
    }
#warning THIS WON'T WORK :(
    else if ( [category isEqualToString:@"gif"] )
    {
        return VInStreamMediaLinkTypeGif;
    }
    else if ( [category isEqualToString:@"video"] )
    {
        return VInStreamMediaLinkTypeVideo;
    }
    return VInStreamMediaLinkTypeUnknown;
}

+ (void)imageAndTextForMediaLinkType:(VInStreamMediaLinkType)linkType dependencyManager:(VDependencyManager *)dependencyManager andCallbackBlock:(void (^)(UIImage *icon, NSString *linkPrompt))callbackBlock
{
#warning NEED TO GET ICONS FROM DEPENDENCY MANAGER
    UIImage *icon = nil;
    NSString *linkPrompt = nil;
    switch (linkType)
    {
        case VInStreamMediaLinkTypeImage:
            icon = [UIImage imageNamed:@"open_image_icon"];
            linkPrompt = @"Open Image";
            break;

        case VInStreamMediaLinkTypeGif:
            icon = [UIImage imageNamed:@"watch_gif_icon"];
            linkPrompt = @"Watch Gif";
            break;
            
        case VInStreamMediaLinkTypeVideo:
            icon = [UIImage imageNamed:@"watch_video_icon"];
            linkPrompt = @"Watch Video";
            break;
            
        default:
            break;
    }
    
    callbackBlock( icon, linkPrompt );
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
