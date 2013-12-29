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
#import "UIView+AutoLayout.h"

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

    CGFloat padding = 20;
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){.size={.height=150}}];
    UIImageView *headerImageView = [UIImageView autoLayoutView];
    headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headerImageView setImageWithURL:[[VThemeManager sharedThemeManager] themedImageURLForKey:kVMenuHeaderImageUrl]];
    [headerView addSubview:headerImageView];
    [headerImageView pinToSuperviewEdges:JRTViewPinTopEdge|JRTViewPinRightEdge|JRTViewPinBottomEdge inset:padding];
    // extra 10 for the offset in the storyboard, which is for the spring animation
    [headerImageView pinToSuperviewEdges:JRTViewPinLeftEdge inset:padding+10];
    self.tableView.tableHeaderView = headerView;
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
