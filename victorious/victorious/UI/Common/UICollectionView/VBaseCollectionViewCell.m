//
//  VBaseCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@implementation VBaseCollectionViewCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
/// When targeting iOS7 and building with Xcode 6 content view's resizing mask is not correct.
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
// End bug fix
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    return layoutAttributes;
}

@end
