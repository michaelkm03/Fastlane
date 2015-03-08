//
//  VNotLoggedInProfileCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotLoggedInProfileCollectionViewCell.h"

#import "UIView+AutoLayout.h"
#import "VNoContentView.h"

@implementation VNotLoggedInProfileCollectionViewCell

- (void)awakeFromNib
{
    VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.bounds];
    noContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:noContentView];
    [self v_addFitToParentConstraintsToSubview:noContentView];
    noContentView.iconImageView.image = [UIImage imageNamed:@"profileGenericUser"];
    noContentView.titleLabel.text = NSLocalizedString(@"You're not logged in!", @"");
    noContentView.messageLabel.text = NSLocalizedString(@"", @"");
}

@end
