//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

#import "VDirectoryItem.h"

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

- (void)setDirectoryItem:(VDirectoryItem *)directoryItem
{
    _directoryItem = directoryItem;
    
    self.nameLabel.text = directoryItem.name;
    
    __weak UIImageView* weakPreviewImageView = self.previewImageView;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:directoryItem.previewImage]];
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
