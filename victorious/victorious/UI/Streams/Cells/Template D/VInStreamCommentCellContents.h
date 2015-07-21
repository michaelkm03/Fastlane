//
//  VInStreamCommentCellContents.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning NEEDS TESTS

@class VDependencyManager, VInStreamMediaLink, VComment;

/**
    A model representing the content that will be displayed by an in stream comment.
 */
@interface VInStreamCommentCellContents : NSObject

/**
    Creates and returns a new VInStreamCommentCellContents based on the provided fields.
 */
- (instancetype)initWithUsername:(NSString *)username
                    usernameFont:(UIFont *)usernameFont
                     commentText:(NSString *)commentText
           commentTextAttributes:(NSDictionary *)commentTextAttributes
       highlightedTextAttributes:(NSDictionary *)highlightedTextAttributes
                    creationDate:(NSDate *)creationDate
         timestampTextAttributes:(NSDictionary *)timestampTextAttributes
               inStreamMediaLink:(VInStreamMediaLink *)inStreamMediaLink
           profileImageUrlString:(NSString *)profileImageUrlString
                         comment:(VComment *)comment;

/**
    A convenience method for creating in stream comments from an array of comments.
 
    @param comments The array of comments that should be translated into VInStreamCommentCellContents.
    @param dependencyManager The dependency manager whose images and color values should be used to
                                populate each VInStreamCommentCellContents in the returned array.
 
    @return An array of VInStreamCommentCellContents objects representing the provided comments.
 */
+ (NSArray *)inStreamCommentsForComments:(NSArray *)comments
                    andDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSString *username; ///< The username of the user who posted the comment
@property (nonatomic, readonly) UIFont *usernameFont; ///< The font of the username
@property (nonatomic, readonly) NSString *commentText; ///< The comment left by the user
@property (nonatomic, readonly) NSDictionary *commentTextAttributes; ///< The attributes for the comment text
@property (nonatomic, readonly) NSDictionary *highlightedTextAttributes; ///< The attributes of highlighted text (tags)
@property (nonatomic, readonly) NSDate *creationDate; ///< The date the comment was created
@property (nonatomic, readonly) NSDictionary *timestampTextAttributes; ///< The text attributes of the timestamp
@property (nonatomic, readonly) VInStreamMediaLink *inStreamMediaLink; ///< The media link representing a piece of media posted in the comment
@property (nonatomic, readonly) NSString *profileImageUrlString; ///< A string representing the url of poster's profile image
@property (nonatomic, readonly) VComment *comment; ///< The comment that this contents object is representing

@end
