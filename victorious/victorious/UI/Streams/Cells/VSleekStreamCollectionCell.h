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

extern const CGFloat kTemplateDHeaderHeight;
extern const CGFloat kTemplateDActionViewHeight;
extern const CGFloat kTemplateDActionViewBottomConstraintHeight;

extern const CGFloat kTemplateDTextNeighboringViewSeparatorHeight;

@interface VSleekStreamCollectionCell : VStreamCollectionCell

@property (nonatomic, weak) IBOutlet VSleekStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;

@end
