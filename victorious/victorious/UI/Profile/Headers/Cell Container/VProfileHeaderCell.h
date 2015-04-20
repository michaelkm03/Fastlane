//
//  VProfileHeaderCell.h
//  victorious
//
//  Created by Will Long on 10/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VProfileHeaderCell : UICollectionViewCell

/**
 Getter/setter for the child header view controller.  Set this property to add as a child
 to the cell.  If the same header view controller is already a child, this is a no-op.  If
 another header view controller instance is present, it will be removed.
 */
@property (nonatomic, weak) UIViewController *headerViewController;

@end
