//
//  VCreateSheetCollectionViewCell.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCreateSheetCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

+ (CGFloat)cellHeight;

@end
