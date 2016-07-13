//
//  VInStreamCommentsCell.h
//  victorious
//
//  Created by Sharif Ahmed on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VInStreamCommentCellContents, VTagSensitiveTextView, VTagDictionary;

/**
    A condensed representation of a comment, intended to be displayed alongside the content that has been commented on.
 */
@interface VInStreamCommentsCell : VBaseCollectionViewCell

/**
    Populates the appropriate fields of this cell from the provided contents.
 
    @param contents The VInStreamCommentCellContents that should be represented by this cell.
 */
- (void)setupWithInStreamCommentCellContents:(VInStreamCommentCellContents *)contents;

/**
    The ideal height for this cell.
 
    @param contents The VInStreamCommentCellContents that will be represented by this cell.
    @param width The maximum width of this cell.
 
    @return The ideal height for this cell.
 */
+ (CGFloat)desiredHeightForCommentCellContents:(VInStreamCommentCellContents *)contents withMaxWidth:(CGFloat)width;

/**
    The preferred reuse identifier for the provided VInStreamCommentCellContents.
 
    @param contents The VInStreamCommentCellContents object that will be represented by the cell.
 
    @return A string representing the preferred reuse identifier for the provided VInStreamCommentCellContents.
 */
+ (NSString *)reuseIdentifierForContents:(VInStreamCommentCellContents *)contents;

/**
    An array of strings representing all possible reuse identifiers for this class.
 */
+ (NSArray *)possibleReuseIdentifiers;

/**
    The comment cell contents currently being displayed by this cell.
 */
@property (nonatomic, readonly) VInStreamCommentCellContents *commentCellContents;

@end
