//
//  VDiscoverTableHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverTableHeaderViewController.h"

@interface VDiscoverTableHeaderViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) NSString *sectionTitle;

@end

@implementation VDiscoverTableHeaderViewController

- (instancetype)initWithSectionTitle:(NSString *)sectionTitle
{
    self = [super init];
    if (self)
    {
        self.sectionTitle = sectionTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sectionTitle = _sectionTitle;
}

- (void)setSectionTitle:(NSString *)sectionTitle
{
    _sectionTitle = sectionTitle;
    self.titleLabel.text = _sectionTitle;
}

@end
