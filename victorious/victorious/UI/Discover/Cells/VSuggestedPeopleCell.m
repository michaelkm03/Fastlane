//
//  VSuggestedPeopleCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPeopleCell.h"
#import "VSuggestedPeople.h"

@interface VSuggestedPeopleCell()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) VSuggestedPeople *suggestedPeople;

@end

@implementation VSuggestedPeopleCell

- (void)awakeFromNib
{
    self.suggestedPeople = [[VSuggestedPeople alloc] initWithCollectionView:self.collectionView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSInteger)cellHeight
{
    return 190.0f;
}

@end
