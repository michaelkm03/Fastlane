//
//  VAssetCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionViewCell.h"

@interface VAssetCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *selectionView;
@property (strong, nonatomic) IBOutlet UIView *durationContainer;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) NSDateComponentsFormatter *dateFormatter;

@end

@implementation VAssetCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        _dateFormatter = [[NSDateComponentsFormatter alloc] init];
        _dateFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorNone;
        _dateFormatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
        _dateFormatter.formattingContext = NSFormattingContextListItem;
        _dateFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.durationContainer.layer.cornerRadius = CGRectGetHeight(self.durationContainer.bounds) * 0.5f;
    self.durationContainer.layer.masksToBounds = YES;
}

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

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.selectionView.alpha = highlighted ? 1.0f : 0.0f;
}

#pragma mark - Property Accessors

- (void)setAsset:(PHAsset *)asset
{
    if (![_asset.localIdentifier isEqualToString:asset.localIdentifier])
    {
        // We now represent a new asset
        self.imageView.image = nil;
    }
    _asset = asset;
    
    [self configureForMediaTypeWithAsset:asset];

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = self.imageView.bounds.size;
    CGSize desiredSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.version = PHImageRequestOptionsVersionCurrent;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.networkAccessAllowed = YES;
    
    if (self.tag)
    {
        [self.imageManager cancelImageRequest:(PHImageRequestID)self.tag];
    }
    
    __weak typeof(self) welf = self;
    self.tag = [self.imageManager requestImageForAsset:asset
                                 targetSize:desiredSize
                                contentMode:PHImageContentModeAspectFill
                                    options:requestOptions
                              resultHandler:^(UIImage *result, NSDictionary *info)
     {
         __strong typeof(welf) strongSelf = welf;
         if ([strongSelf.asset.localIdentifier isEqualToString:asset.localIdentifier])
         {
             strongSelf.imageView.image = result;
         }
     }];
}

#pragma mark - Private Methods

- (void)configureForMediaTypeWithAsset:(PHAsset *)asset
{
    if (asset.mediaType == PHAssetMediaTypeVideo)
    {
        self.durationContainer.hidden = NO;
        self.durationLabel.text = [self.dateFormatter stringFromTimeInterval:asset.duration];
    }
    else
    {
        self.durationContainer.hidden = YES;
    }
}

@end
