//
//  VInStreamCommentsController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VInStreamCommentCellContents, VInStreamCommentsShowMoreAttributes;

/**
    An object that controls the display of in stream comments.
 */
@interface VInStreamCommentsController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (instancetype)init NS_UNAVAILABLE;

/**
    The designated initializer for this class, performs basic setup on the provided collection view.
 
    @param collectionView The collection view that should display in stream comments. Must not be nil.
 
    @return A new in stream comments controller with a configured collection view.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

/**
    Prepares the collection view with the provided array of comment cell contents and show more cell visibility.
 
    @param commentCellContents An array of VInStreamCommentCellContents that should populate the collection view.
    @param visible Whether or not the show more cell is visible.
 */
- (void)setupWithCommentCellContents:(NSArray *)commentCellContents
             withShowMoreCellVisible:(BOOL)visible;

/**
 The desired height of the collection view for the provided parameters.
 
 @param commentCellContents An array of VInStreamCommentCellContents representing comments that should be displayed.
 @param width The maximum width the cell can have. This should be the collection view's width minus any pertinent insets.
 @param attributes The display attributes for the show more cell.
 @param enabled Whether or not the show the "show more" cell.
 
 @return The ideal height for the collection view.
 */
+ (CGFloat)desiredHeightForCommentCellContents:(NSArray *)commentCellContents
                                  withMaxWidth:(CGFloat)width
                            showMoreAttributes:(VInStreamCommentsShowMoreAttributes *)attributes
                andShowMoreCommentsCellEnabled:(BOOL)enabled;


/**
    The display attributes of the show more cell.
 */
@property (nonatomic, strong) VInStreamCommentsShowMoreAttributes *showMoreAttributes;

/**
    The collection view that houses in stream comments.
 */
@property (nonatomic, readonly) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat leftInset;

@end
