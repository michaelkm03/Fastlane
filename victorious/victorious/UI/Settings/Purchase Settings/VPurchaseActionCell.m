//
//  VPurchaseActionCell.m
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseActionCell.h"

@interface VPurchaseActionCell ()

@property (strong, nonatomic) void(^actionCallback)(VPurchaseActionCell *);

@end

@implementation VPurchaseActionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setAction:(void(^)(VPurchaseActionCell *))actionCallback
{
    self.actionCallback = actionCallback;
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
