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

#import "VThemeManager.h"

NSString * const kVStreamDirectoryItemCellName = @"VStreamDirectoryItemCell";

@interface VDirectoryItemCell()

@property (nonatomic, strong) IBOutlet UIImageView* previewImageView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@end

@implementation VDirectoryItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    
    __weak UIImageView* weakPreviewImageView = self.previewImageView;
    //TODO: this should eventually do something nifty with multiple images.
    NSString *previewImagePath = streamItem.previewImagePath;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:previewImagePath]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         __strong UIImageView* strongPreviewImageView = weakPreviewImageView;
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

@end
