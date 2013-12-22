//
//  VFeaturedViewController.m
//  victoriOS
//
//  Created by David Keegan on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VFeaturedViewController.h"
#import "VSequence.h"

@interface VFeaturedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation VFeaturedViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.label.text = self.sequence.name;
    [self.imageView setImageWithURL:[NSURL URLWithString:self.sequence.previewImage]
                   placeholderImage:[UIImage new]];
}

@end
