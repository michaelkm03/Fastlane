//
//  VMenuTableViewController.m
//  victorious
//
//  Created by David Keegan on 12/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VMenuTableViewController.h"
#import "VThemeManager.h"

@interface VMenuTableViewController()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *separatorViews;
@end

@implementation VMenuTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    NSString *channelName = [[VThemeManager sharedThemeManager] themedValueForKeyPath:@"channel.name"];
    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Channel", @"<CHANNEL NAME> Channel"), channelName];

    [[UIImageView appearanceWhenContainedIn:[self class], nil]
     setTintColor:[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.icon"]];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop){
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop){
        label.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.menu"];
        label.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.label"];
    }];
    [self.separatorViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop){
        view.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.separator"];
    }];

    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
