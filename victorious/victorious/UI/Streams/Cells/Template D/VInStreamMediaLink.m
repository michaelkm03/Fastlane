//
//  VInStreamMediaLink.m
//  victorious
//
//  Created by Sharif Ahmed on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamMediaLink.h"
#import "VDependencyManager.h"

static NSString * const kImageIconKey = @"open_image_icon";
static NSString * const kVideoIconKey = @"watch_video_icon";
static NSString * const kGifIconKey = @"watch_gif_icon";

@implementation VInStreamMediaLink

+ (instancetype)newWithTintColor:(UIColor *)tintColor
                            font:(UIFont *)font
                        linkType:(VCommentMediaType)linkType
                       urlString:(NSString *)urlString
            andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(urlString != nil);
    NSParameterAssert(dependencyManager != nil);
    
    __block NSString *linkLabelText;
    __block UIImage *linkIcon;
    
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
                         linkType:(VCommentMediaType)linkType
                        urlString:(NSString *)urlString
{
    NSParameterAssert(urlString != nil);
    
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

+ (void)imageAndTextForMediaLinkType:(VCommentMediaType)linkType dependencyManager:(VDependencyManager *)dependencyManager andCallbackBlock:(void (^)(UIImage *icon, NSString *linkPrompt))callbackBlock
{
    NSString *iconKey = nil;
    NSString *linkPrompt = nil;
    switch (linkType)
    {
        case VCommentMediaTypeImage:
            iconKey = kImageIconKey;
            linkPrompt = @"Open Image";
            break;

        case VCommentMediaTypeGIF:
            iconKey = kGifIconKey;
            linkPrompt = @"Watch Gif";
            break;
            
        case VCommentMediaTypeVideo:
            iconKey = kVideoIconKey;
            linkPrompt = @"Watch Video";
            break;
            
        default:
            break;
    }
    
    callbackBlock( [dependencyManager imageForKey:iconKey], NSLocalizedString(linkPrompt,nil) );
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
