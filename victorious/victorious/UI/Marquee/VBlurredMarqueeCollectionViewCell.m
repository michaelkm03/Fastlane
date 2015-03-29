//
//  VBlurredMarqueeCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredMarqueeCollectionViewCell.h"
#import "VBlurredMarqueeStreamItemCell.h"
#import "VStreamItem+Fetcher.h"
#import "VCrossFadingImageView.h"
#import "VCrossFadingLabel.h"
#import "VStream.h"
#import "VDependencyManager.h"
#import "UIImage+ImageCreation.h"
#import "VAbstractMarqueeController.h"
#import <FBKVOController.h>

@interface VBlurredMarqueeCollectionViewCell ()

@property (nonatomic, strong) VStream *stream;
@property (nonatomic, weak) IBOutlet VCrossFadingImageView *crossfadingBlurredImageView;
@property (nonatomic, weak) IBOutlet VCrossFadingLabel *crossfadingLabel;

@end

@implementation VBlurredMarqueeCollectionViewCell

- (void)awakeFromNib
{
    [self.collectionView registerNib:[VBlurredMarqueeStreamItemCell nibForCell] forCellWithReuseIdentifier:[VBlurredMarqueeStreamItemCell suggestedReuseIdentifier]];
}

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    [self streamItemsUpdated];
}

- (void)setMarquee:(VAbstractMarqueeController *)marquee
{
    [super setMarquee:marquee];
    self.stream = marquee.stream;
    [self.KVOController observe:self.stream
                        keyPath:@"streamItems"
                        options:0
                         action:@selector(streamItemsUpdated)];
    [self.KVOController observe:self.collectionView
                        keyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                         action:@selector(contentOffsetChanged:)];
}

- (void)streamItemsUpdated
{
    if ( self.stream.streamItems.count == 0 )
    {
        return;
    }
    
    NSMutableArray *previewImages = [[NSMutableArray alloc] init];
    NSMutableArray *contentNames = [[NSMutableArray alloc] init];
    for ( VStreamItem *streamItem in self.stream.streamItems )
    {
        NSArray *previewImagePaths = streamItem.previewImagePaths;
        if ( previewImagePaths.count > 0 )
        {
            [previewImages addObject:[NSURL URLWithString:[previewImagePaths firstObject]]];
        }
        [contentNames addObject:streamItem.name];
    }
    
    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.crossfadingBlurredImageView setCrossFadingImageWithURLs:[NSArray arrayWithArray:previewImages] tintColor:linkColor andPlaceholderImage:[UIImage resizeableImageWithColor:linkColor]];
    
    [self.crossfadingLabel setupWithStrings:contentNames andTextAttributes:[self labelTextAttributes]];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    self.crossfadingLabel.textAttributes = [self labelTextAttributes];
}

- (NSDictionary *)labelTextAttributes
{
    if ( self.dependencyManager == nil )
    {
        return nil;
    }
    
    return @{
             NSFontAttributeName : [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
             NSForegroundColorAttributeName : [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]
             };
}

- (void)contentOffsetChanged:(NSDictionary *)changeDictionary
{
    NSValue *newContentOffset = [changeDictionary objectForKey:@"new"];
    if ( newContentOffset != nil )
    {
        CGPoint point = newContentOffset.CGPointValue;
        CGFloat newOffset = point.x / CGRectGetWidth(self.bounds);
        self.crossfadingBlurredImageView.offset = newOffset;
        self.crossfadingLabel.offset = newOffset;
    }
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return [VBlurredMarqueeStreamItemCell desiredSizeWithCollectionViewBounds:bounds];
}

@end
