//
//  VMenuTableViewController.m
//  victorious
//
//  Created by David Keegan on 12/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VMenuTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "VThemeManager.h"

@interface VMenuTableViewController()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@end

@implementation VMenuTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.nameLabel.text = [[VThemeManager sharedThemeManager] themedValueForKey:kVApplicationName];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop){
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];

    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;

//    UIView *headerView = [UIView new];
//    UIImageView *headerImageView = [UIImageView new];
//    headerImageView.contentMode = UIViewContentModeCenter;
//    [headerImageView setImageWithURL:[[VThemeManager sharedThemeManager] themedImageURLForKey:kVMenuHeaderImageUrl]];
//    self.tableView.tableHeaderView = headerView;
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
