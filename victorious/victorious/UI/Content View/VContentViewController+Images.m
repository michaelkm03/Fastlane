//
//  VContentViewController+Images.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController+Images.h"
#import "VContentViewController+Private.h"

@implementation VContentViewController (Images)

- (void)loadImage
{
    NSURL* imageUrl;
    if ([self.currentAsset.type isEqualToString:VConstantsMediaTypeImage])
    {
        imageUrl = [NSURL URLWithString:self.currentAsset.data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImage];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    
    [self.previewImage setImageWithURLRequest:request
                             placeholderImage:placeholderImage
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         CGFloat yRatio = 1;
         CGFloat xRatio = 1;
         self.previewImage.image = image;
         if (self.previewImage.image.size.height < self.previewImage.image.size.width)
         {
             yRatio = self.previewImage.image.size.height / self.previewImage.image.size.width;
         }
         else if (self.previewImage.image.size.height > self.previewImage.image.size.width)
         {
             xRatio = self.previewImage.image.size.width / self.previewImage.image.size.height;
         }
         CGFloat videoHeight = self.mediaView.frame.size.width * yRatio;
         CGFloat videoWidth = self.mediaView.frame.size.width * xRatio;
         self.previewImage.frame = CGRectMake(0, 0, videoWidth, videoHeight);
         
         self.previewImage.hidden = NO;
     }
                                      failure:nil];
    
    self.pollPreviewView.hidden = YES;
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = YES;
    
    [self updateActionBar];
}

@end
