//
//  VInStreamCommentCellContents.m
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentCellContents.h"
#import "VComment.h"
#import "VUser.h"
#import "VDependencyManager.h"
#import "VInStreamMediaLink.h"

@implementation VInStreamCommentCellContents

- (instancetype)initWithUsername:(NSString *)username
          usernameTextAttributes:(NSDictionary *)usernameTextAttributes
                         comment:(NSString *)comment
           commentTextAttributes:(NSDictionary *)commentTextAttributes
       highlightedTextAttributes:(NSDictionary *)highlightedTextAttributes
                    creationDate:(NSDate *)creationDate
         timestampTextAttributes:(NSDictionary *)timestampTextAttributes
               inStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
           profileImageUrlString:(NSString *)profileImageUrlString
                       commentId:(NSNumber *)commentId
{
    self = [super init];
    if ( self != nil )
    {
        _username = username ?: @"";
        _usernameTextAttributes = usernameTextAttributes;
        _comment = comment ?: @"";
        _commentTextAttributes = commentTextAttributes;
        _highlightedTextAttributes = highlightedTextAttributes;
        _creationDate = creationDate;
        _timestampTextAttributes = timestampTextAttributes;
        _inStreamMediaLink = inStreamMediaLink;
        _profileImageUrlString = profileImageUrlString;
        _commentId = commentId;
    }
    return self;
}

+ (NSArray *)inStreamCommentsForComments:(NSArray *)comments andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(comments != nil);
    NSParameterAssert(dependencyManager != nil);
    
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    for ( VComment *comment in comments )
    {
        UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        UIColor *mainTextColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        UIColor *timestampTextColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        
        UIFont *usernameFont = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        UIFont *commentFont = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        UIFont *timestampFont = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        UIFont *mediaLinkFont = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
        
        VInStreamMediaLink *mediaLink = nil;
        NSString *mediaUrl = comment.mediaUrl;
        if ( mediaUrl.length > 0 )
        {
            mediaLink = [VInStreamMediaLink newWithTintColor:linkColor
                                                        font:mediaLinkFont
                                                   mediaType:comment.mediaType
                                                   urlString:mediaUrl];
        }
        
        VInStreamCommentCellContents *content = [[VInStreamCommentCellContents alloc]
                                                 initWithUsername:comment.user.name
                                                 usernameTextAttributes:@{ NSForegroundColorAttributeName : linkColor, NSFontAttributeName : usernameFont }
                                                 comment:comment.text
                                                 commentTextAttributes:@{ NSForegroundColorAttributeName : mainTextColor, NSFontAttributeName : commentFont }
                                                 highlightedTextAttributes:@{ NSForegroundColorAttributeName : linkColor, NSFontAttributeName : commentFont }
                                                 creationDate:comment.postedAt
                                                 timestampTextAttributes:@{ NSForegroundColorAttributeName : timestampTextColor, NSFontAttributeName : timestampFont }
                                                 inStreamMediaLink:mediaLink
                                                 profileImageUrlString:comment.user.pictureUrl
                                                 commentId:comment.remoteId];
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
    BOOL equalCommentIds = [self.commentId isEqualToNumber:inStreamCommentCellContents.commentId];
    BOOL equalUsernames = [self.username isEqualToString:inStreamCommentCellContents.username] || ( self.username == nil && inStreamCommentCellContents.username == nil );
    BOOL equalComments = [self.comment isEqualToString:inStreamCommentCellContents.comment] || ( self.comment == nil && inStreamCommentCellContents.comment == nil );
    BOOL equalCreationDates = [self.creationDate isEqualToDate:inStreamCommentCellContents.creationDate] || ( self.creationDate == nil && inStreamCommentCellContents.creationDate == nil );
    BOOL equalMediaLinkTexts = [self.inStreamMediaLink isEqual:inStreamCommentCellContents.inStreamMediaLink] || ( self.inStreamMediaLink == nil && inStreamCommentCellContents.inStreamMediaLink == nil );
    BOOL equalProfileImageUrlStrings = [self.profileImageUrlString isEqualToString:inStreamCommentCellContents.profileImageUrlString] || ( self.profileImageUrlString == nil && inStreamCommentCellContents.profileImageUrlString == nil );
    return equalCommentIds && equalUsernames && equalComments && equalCreationDates && equalMediaLinkTexts && equalProfileImageUrlStrings;
}

- (NSUInteger)hash
{
    //Hash based on commentId, username, comment, creation date, media link text, and profile image url string
    NSString *hashString = [NSString stringWithFormat:@"i%@", self.commentId];
    
    if ( self.username != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"u%@", self.username]];
    }
    if ( self.comment != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"c%@", self.comment]];
    }
    if ( self.creationDate != nil )
    {
        hashString = [hashString stringByAppendingString:[NSString stringWithFormat:@"d%@", self.creationDate]];
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
