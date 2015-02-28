//
//  VDirectorySeeMoreItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VDirectorySeeMoreItemCell : VBaseCollectionViewCell

- (void)updateBottomConstraintToConstant:(CGFloat)constant;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *imageColor;

@property (nonatomic, weak) IBOutlet UILabel *seeMoreLabel;

@end
