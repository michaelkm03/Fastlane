//
//  VStreamCollectionCell-D.h
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"
#import "VSequenceActionsDelegate.h"

@class VSleekStreamCellActionView;

//Subviews should use the following cell subview height values to determine desired and actual cell height
extern const CGFloat kSleekCellHeaderHeight;
extern const CGFloat kSleekCellActionViewHeight;
extern const CGFloat kSleekCellActionViewBottomConstraintHeight; ///< The space between bottom of actionView and bottom of cell

extern const CGFloat kSleekCellTextNeighboringViewSeparatorHeight; ///< The space between the top of the textView and the content and between the bottom of the comment label and the actionView

@interface VSleekStreamCollectionCell : VStreamCollectionCell

@property (nonatomic, weak) IBOutlet VSleekStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;

@end
