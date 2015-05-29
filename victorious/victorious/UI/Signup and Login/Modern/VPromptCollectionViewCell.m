//
//  VPromptCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPromptCollectionViewCell.h"

@interface VPromptCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@end

@implementation VPromptCollectionViewCell

#pragma mark - Public

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    self.promptLabel.attributedText = attributedTitle;
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return bounds.size;
}

@end
