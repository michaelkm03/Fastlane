//
//  VDiscoverTableHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverTableHeaderViewController.h"
#import "VThemeManager.h"

@interface VDiscoverTableHeaderViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) NSString *sectionTitle;
@property (nonatomic, assign) BOOL shouldApplyHeightAdjustment;

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

- (void)applyTheme
{
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionTitle = _sectionTitle;
}

- (void)setSectionTitle:(NSString *)sectionTitle
{
    _sectionTitle = sectionTitle;
    self.titleLabel.text = [_sectionTitle uppercaseString];
    
    [self applyTheme];
}

@end
