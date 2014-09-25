//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

#import "VStreamItem+Fetcher.h"

#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"

NSString * const VDirectoryItemCellNameStream = @"VStreamDirectoryItemCell";

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView *previewImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic) CGRect originalNameLabelFrame;

@end

@implementation VDirectoryItemCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    CGFloat height = width * 1.372;//from spec, 398 height for 290 width
    return CGSizeMake(width, height);
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.originalNameLabelFrame = self.nameLabel.frame;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    [self.nameLabel sizeToFit];
    
    __weak UIImageView *weakPreviewImageView = self.previewImageView;
    //TODO: this should eventually do something nifty with multiple images.
    NSString *previewImagePath = [streamItem.previewImagePaths firstObject];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:previewImagePath]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:[UIImage resizeableImageWithColor:
                                                   [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         __strong UIImageView *strongPreviewImageView = weakPreviewImageView;
         if (!request)
         {
             strongPreviewImageView.image = image;
             return;
         }
         
         strongPreviewImageView.alpha = 0;
         strongPreviewImageView.image = image;
         [UIView animateWithDuration:.3f animations:^
          {
              strongPreviewImageView.alpha = 1;
          }];
     }
                                          failure:nil
     ];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.nameLabel.frame = self.originalNameLabelFrame;
}

@end
