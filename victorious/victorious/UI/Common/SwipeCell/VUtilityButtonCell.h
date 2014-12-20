//
//  VUtilityButtonCell.h
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VUtilityButtonConfig : NSObject

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface VUtilityButtonCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;

/**
 Sets the width of each utility button to be used for layout and as a scroll
 animation target.  The utility buttons are revealed in a way where they are dynamically
 sized depending on how far the cell has been swiped, and this value is important
 for making sure things look and move correctly.
 */
@property (nonatomic, assign) CGFloat intendedFullWidth;

/**
 Configures properties of the cell and its subviews according to properties of
 the provided VUtilityButtonConfig object.
 */
- (void)applyConfiguration:(VUtilityButtonConfig *)config;

@end
