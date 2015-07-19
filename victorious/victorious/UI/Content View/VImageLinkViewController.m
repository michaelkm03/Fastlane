//
//  VImageLinkViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageLinkViewController.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"

@interface VImageLinkViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation VImageLinkViewController

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super initWithUrlString:urlString];
    if ( self != nil )
    {
        _imageView = [[UIImageView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.contentContainerView addSubview:self.imageView];
    [self.contentContainerView v_addFitToParentConstraintsToSubview:self.imageView];
}

- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock
{
    [self.imageView fadeInImageAtURL:[NSURL URLWithString:self.mediaUrlString]
                    placeholderImage:nil
                          completion:^(UIImage *image)
     {
         CGFloat aspectRatio = 1.0f;
         if ( image != nil )
         {
             CGSize size = self.imageView.image.size;
             aspectRatio = size.width / size.height;
         }
         completionBlock( aspectRatio );
     }];
}

@end
