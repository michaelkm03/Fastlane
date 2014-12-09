//
//  VPurchaseActionCell.m
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseActionCell.h"
#import "VButton.h"
#import "VThemeManager.h"

@interface VPurchaseActionCell ()

@property (weak, nonatomic) IBOutlet VButton *button;
@property (strong, nonatomic) void(^actionCallback)(VPurchaseActionCell *);

@end

@implementation VPurchaseActionCell

- (void)setAction:(void(^)(VPurchaseActionCell *))actionCallback withTitle:(NSString *)labelTitle
{
    self.actionCallback = actionCallback;
    [self.button setTitle:labelTitle forState:UIControlStateNormal];
    self.button.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.button.style = VButtonStylePrimary;
}

#pragma mark - IBActions

- (IBAction)onButtonTapped:(id)sender
{
    if ( self.actionCallback != nil )
    {
        self.actionCallback( self );
    }
}

@end
