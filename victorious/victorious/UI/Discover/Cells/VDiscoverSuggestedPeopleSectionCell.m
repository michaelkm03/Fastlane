//
//  VSuggestedPeopleCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverSuggestedPeopleSectionCell.h"
#import "VDiscoverSuggestedPersonCell.h"
#import "VDependencyManager.h"

@implementation VDiscoverSuggestedPeopleSectionCell

+ (CGFloat)cellHeight
{
    return [VDiscoverSuggestedPersonCell cellHeight];
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
