//
//  VInsetStreamCollectionCell.h
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

@class VStreamCellActionView;

//Subviews should use the following cell subview height values to determine desired and actual cell height
extern const CGFloat kInsetCellHeaderHeight;
extern const CGFloat kInsetCellActionViewHeight;

extern const CGFloat kInsetCellTextNeighboringViewSeparatorHeight; // This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VInsetStreamCollectionCell : VStreamCollectionCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentsLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;

@end
