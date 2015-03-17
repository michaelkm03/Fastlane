//
//  VInsetStreamCollectionCell.h
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

@class VStreamCellActionView;

@interface VInsetStreamCollectionCell : VStreamCollectionCell

@property (nonatomic, weak) IBOutlet VStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentsLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;

@end
