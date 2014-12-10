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
@property (weak, nonatomic) IBOutlet UIView *loadingOverlay;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (strong, nonatomic) void(^actionCallback)(VPurchaseActionCell *);

@end

@implementation VPurchaseActionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.button.style = VButtonStylePrimary;
}

- (void)setAction:(void(^)(VPurchaseActionCell *))actionCallback
{
    self.actionCallback = actionCallback;
}

- (void)setIsActionEnabled:(BOOL)isActionEnabled withTitle:(NSString *)labelTitle
{
    if ( isActionEnabled )
    {
        [self.button setTitle:labelTitle forState:UIControlStateNormal];
        self.button.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    else
    {
        [self.button setTitle:nil forState:UIControlStateNormal];
        self.loadingLabel.text = labelTitle;
        self.button.backgroundColor = [UIColor grayColor];
    }
    
    self.button.enabled = isActionEnabled;
    self.loadingOverlay.hidden = isActionEnabled;
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
