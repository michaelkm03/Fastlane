//
//  VNoContentView.h
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VNoContentView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (instancetype)noContentViewWithFrame:(CGRect)frame;

@end
