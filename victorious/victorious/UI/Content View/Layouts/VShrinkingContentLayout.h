//
//  VShrinkingContentLayout.h
//  victorious
//
//  Created by Michael Sena on 9/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewBaseLayout.h"

typedef NS_ENUM(NSInteger, VContentViewSection)
{
    VContentViewSectionContent,
    VContentViewSectionHistogram,
    VContentViewSectionTicker,
    VContentViewSectionAllComments,
    VContentViewSectionCount
};

UIKIT_EXTERN NSString *const VShrinkingContentLayoutContentBackgroundView;
UIKIT_EXTERN NSString *const VShrinkingContentLayoutAllCommentsHandle;

/**
 *  Shrinking Content Layout. Lays out content/histogram/ticker from top top bottom in order for single cells. All Comments begin at the bounds of the collectionview height and subtracting the allCommentsHandleBottomInset property. Further comments are laid out below the handle header for all comments section. NOTE: Relies on the collectionView's delegate to implement UICollectionViewDelegateFlowLayout protocol.
 */
@interface VShrinkingContentLayout : UICollectionViewLayout


/**
 *  The amount to inset the AllComments section from the bottom. (Includes drawer header)
 */
@property (nonatomic, assign) CGFloat allCommentsHandleBottomInset;

@end
