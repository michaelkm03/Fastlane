//
//  VAbstractConnectViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractConnectViewController.h"
#import "VThemeManager.h"

@interface VAbstractConnectViewController ()
@property (nonatomic, weak)     IBOutlet    UILabel*        headlineLabel;
@property (nonatomic, weak)     IBOutlet    UILabel*        privacyLabel;
@property (nonatomic, weak)     IBOutlet    UIView*         shadowView;
@end

@implementation VAbstractConnectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1.0].CGColor;

    self.headlineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.headlineLabel.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    
    self.connectButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    [self.connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.connectButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.privacyLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.privacyLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1.0];
    
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 4.0);
    self.shadowView.layer.shadowRadius = 4.0;
    self.shadowView.layer.shadowOpacity = 1.0;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds].CGPath;
}

- (IBAction)connect:(id)sender
{
    
}

@end
