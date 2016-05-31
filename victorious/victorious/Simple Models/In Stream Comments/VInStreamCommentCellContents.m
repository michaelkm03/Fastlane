//
//  VInStreamCommentCellContents.m
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentCellContents.h"
#import "VComment.h"
#import "VDependencyManager.h"
#import "VInStreamMediaLink.h"
#import "VTagStringFormatter.h"
#import "VCommentMediaTypeHelper.h"
#import "VMediaAttachment.h"
#import "victorious-Swift.h"

@implementation VInStreamCommentCellContents

- (instancetype)initWithUsername:(NSString *)username
                    usernameFont:(UIFont *)usernameFont
                     commentText:(NSString *)commentText
           commentTextAttributes:(NSDictionary *)commentTextAttributes
       highlightedTextAttributes:(NSDictionary *)highlightedTextAttributes
               inStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
           profileImageUrlString:(NSString *)profileImageUrlString
                         comment:(VComment *)comment
{
    NSParameterAssert(comment != nil);
    
    self = [super init];
    if ( self != nil )
    {
        _username = username ?: @"";
        _usernameFont = usernameFont;
        _commentText = commentText ?: @"";
        _commentTextAttributes = commentTextAttributes;
        _highlightedTextAttributes = highlightedTextAttributes;
        _inStreamMediaLink = inStreamMediaLink;
        _profileImageUrlString = profileImageUrlString;
        _comment = comment;
    }
    return self;
}

+ (NSArray *)inStreamCommentsForComments:(NSArray *)comments andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(dependencyManager != nil);
    
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    for ( NSUInteger index = 0; index < comments.count; index ++ )
    {
        VComment *comment = comments[index];
        UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        UIColor *mainTextColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        
        UIFont *usernameFont = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        UIFont *commentFont = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        UIFont *mediaLinkFont = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        
        VInStreamMediaLink *mediaLink = nil;
        NSString *mediaUrlString = comment.mediaUrl;
        if ( mediaUrlString.length > 0 )
        {
            NSURL *mediaUrl = [NSURL URLWithString:mediaUrlString];
            VCommentMediaType linkType = [VCommentMediaTypeHelper mediaTypeForUrl:mediaUrl andShouldAutoplay:[comment.shouldAutoplay boolValue]];
            mediaLink = [VInStreamMediaLink newWithTintColor:linkColor
                                                        font:mediaLinkFont
                                                    linkType:linkType
                                                         url:mediaUrl
                                        andDependencyManager:dependencyManager];
        }
        
        NSString *tappableUserName = [VTagStringFormatter databaseFormattedStringFromUser:comment.user];
        NSMutableDictionary *commentTextAttributes = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *highlightTextAttributes = [[NSMutableDictionary alloc] init];
        
        if ( commentFont != nil )
        {
            [commentTextAttributes setObject:commentFont forKey:NSFontAttributeName];
            [highlightTextAttributes setObject:commentFont forKey:NSFontAttributeName];
        }
        if ( mainTextColor != nil )
        {
            [commentTextAttributes setObject:mainTextColor forKey:NSForegroundColorAttributeName];
        }
        if ( linkColor != nil )
        {
            [highlightTextAttributes setObject:linkColor forKey:NSForegroundColorAttributeName];
        }
        
        VInStreamCommentCellContents *content = [[VInStreamCommentCellContents alloc] initWithUsername:tappableUserName
                                                                                          usernameFont:usernameFont
                                                                                           commentText:comment.text
                                                                                 commentTextAttributes:commentTextAttributes
                                                                             highlightedTextAttributes:highlightTextAttributes
                                                                                     inStreamMediaLink:mediaLink
                                                                                 profileImageUrlString:[comment.user pictureURLOfMinimumSize:VUser.defaultSmallMinimumPictureSize].absoluteString
                                                                                               comment:comment];
        [contents addObject:content];
    }
    return contents;
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
    
    return [self isEqualToInStreamCommentCellContents:object];
}

- (BOOL)isEqualToInStreamCommentCellContents:(VInStreamCommentCellContents *)inStreamCommentCellContents
{
    //is equal based on commentId, username, comment, creation date, media link text, and profile image url string
    BOOL equalCommentIds = [self.comment.remoteId isEqualToNumber:inStreamCommentCellContents.comment.remoteId];
    BOOL equalUsernames = [self.username isEqualToString:inStreamCommentCellContents.username] || ( self.username == nil && inStreamCommentCellContents.username == nil );
    BOOL equalComments = [self.commentText isEqualToString:inStreamCommentCellContents.commentText] || ( self.commentText == nil && inStreamCommentCellContents.commentText == nil );
    BOOL equalMediaLinkTexts = [self.inStreamMediaLink isEqual:inStreamCommentCellContents.inStreamMediaLink] || ( self.inStreamMediaLink == nil && inStreamCommentCellContents.inStreamMediaLink == nil );
    BOOL equalProfileImageUrlStrings = [self.profileImageUrlString isEqualToString:inStreamCommentCellContents.profileImageUrlString] || ( self.profileImageUrlString == nil && inStreamCommentCellContents.profileImageUrlString == nil );
    return equalCommentIds && equalUsernames && equalComments && equalMediaLinkTexts && equalProfileImageUrlStrings;
}

- (NSUInteger)hash
{
    //Hash based on commentId, username, comment, creation date, media link text, and profile image url string
    NSString *hashString = [NSString stringWithFormat:@"i%@", self.comment.remoteId];
    
    if ( self.username != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"u%@", self.username]];
    }
    if ( self.comment != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"c%@", self.comment]];
    }
    if ( self.inStreamMediaLink != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"m%@", self.inStreamMediaLink]];
    }
    if ( self.profileImageUrlString != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"p%@", self.profileImageUrlString]];
    }
    
    return [hashString hash];
}

@end
