//
//  VBasicToolPickerCell.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/*
 The basic tool picker cell is used for representing a string within a UICollectionViewCell.
 */
@interface VBasicToolPickerCell : VBaseCollectionViewCell

/**
 *  The label to manipulate text in.
 */
@property (nonatomic, weak, readonly) IBOutlet UILabel *label;

@end
