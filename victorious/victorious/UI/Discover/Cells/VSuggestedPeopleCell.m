//
//  VSuggestedPeopleCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeopleCell.h"
#import "VSuggestedPersonCollectionViewCell.h"
#import "VDependencyManager.h"

@implementation VSuggestedPeopleCell

+ (CGFloat)cellHeight
{
    return [VSuggestedPersonCollectionViewCell cellHeight];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    self.contentView.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
}

@end
