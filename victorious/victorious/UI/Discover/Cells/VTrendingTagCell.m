//
//  VTrendingTagCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrendingTagCell.h"

@interface VTrendingTagCell()

@property (nonatomic, strong) IBOutlet UILabel *hashTagLabel;

@end

@implementation VTrendingTagCell

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (NSInteger)cellHeight
{
    return 40.0f;
}

- (void)setHashTag:(NSString *)hashTag
{
    _hashTag = hashTag;
    self.hashTagLabel.text = hashTag;
}

@end
