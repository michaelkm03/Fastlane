//
//  VSnapshotViewController.m
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSnapshotViewController.h"

@interface VSnapshotViewController ()

@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;

@end

@implementation VSnapshotViewController

- (void)setButtonEnabled:(BOOL)buttonEnabled
{
    self.snapshotButton.enabled = buttonEnabled;
}

- (BOOL)buttonEnabled
{
    return self.snapshotButton.enabled;
}

#pragma mark - Target/Action

- (IBAction)takeSnapshot:(id)sender
{
    [self.delegate snapshotViewControllerWantsSnapshot:self];
}

@end
