//
//  VMenuViewController.m
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VMenuViewController.h"

@interface VMenuViewController ()

@end

@implementation VMenuViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
