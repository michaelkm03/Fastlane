//
//  VTimeMarkView.m
//  victorious
//
//  Created by Steven F Petteruti on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTimeMarkView.h"

@implementation VTimeMarkView


- (void)awakeFromNib
{
    /*
    int kNumberOfTimeLabels = 13;
    for (int i = 0; i < kNumberOfTimeLabels; i++)
    {
        UIView *hash = [[UIView alloc] initWithFrame:CGRectMake((i*CGRectGetWidth(self.bounds))/(kNumberOfHashes-1), 0, 20, 20)];
        hash.backgroundColor = [UIColor redColor];
        [self addSubview:hash];
    }*/
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.timeLabel.text  = @"00:00";
    self.timeLabel.textColor = [UIColor redColor];
    self.timeLabel.layer.borderColor = [UIColor blueColor].CGColor;
    self.timeLabel.layer.borderWidth = 2.0f;
    [self addSubview:self.timeLabel];
    
    NSLog(@"awaking the timeview from nib");
}

+ (id)collectionReusableViewForCollectionView:(UICollectionView*)collectionView
                                      fromNib:(UINib*)nib
                                 forIndexPath:(NSIndexPath*)indexPath
                                     withKind:(NSString*)kind{
    
    NSString *cellIdentifier = [self cellIdentifier];
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier];
    [collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier];
    VTimeMarkView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
}

+(id)collectionReusableViewForCollectionView:(UICollectionView*)collectionView
                                forIndexPath:(NSIndexPath*)indexPath withKind:(NSString*)kind
{
    return [[self class] collectionReusableViewForCollectionView:collectionView
                                                         fromNib:[self nib]
                                                    forIndexPath:indexPath
                                                        withKind:kind];
}

+ (NSString *)nibName
{
    return [self cellIdentifier];
}

+ (NSString *)cellIdentifier
{
    static NSString* _cellIdentifier = nil;
    _cellIdentifier = NSStringFromClass([self class]);
    return _cellIdentifier;
}

+(UINib*)nib
{
    NSBundle * classBundle = [NSBundle bundleForClass:[self class]];
    UINib * nib = [UINib nibWithNibName:[self nibName]
                                 bundle:classBundle];
    return nib;
}


@end
