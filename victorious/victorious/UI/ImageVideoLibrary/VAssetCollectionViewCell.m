//
//  VAssetCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionViewCell.h"

@interface VAssetCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIView *selectionView;

@end

@implementation VAssetCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.selectionView.alpha = 0.0f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.selectionView.alpha = selected ? 1.0f : 0.0f;
}

@end
