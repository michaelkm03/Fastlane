//
//  VWorkspaceToolButton.h
//  victorious
//
//  Created by Michael Sena on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VWorkspaceTool.h"

@interface VWorkspaceToolButton : UIButton

@property (nonatomic, weak) id <VWorkspaceTool> tool;

@property (nonatomic, copy) UIColor *selectedColor;

@property (nonatomic, copy) UIColor *unselectedColor;

@end
