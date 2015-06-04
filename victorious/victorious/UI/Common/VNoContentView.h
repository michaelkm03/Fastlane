//
//  VNoContentView.h
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

extern float const kPaddingTop;
extern float const kImageHeight;
extern float const kVerticleSpace1;
extern float const kVerticleSpace2;
extern float const kPaddingBottom;

extern float const kPreferredWidthOfMessage;

@interface VNoContentView : UIView <VHasManagedDependencies>

/**
 *  Use this factory method to create VNoContentViews.
 */
+ (instancetype)noContentViewWithFrame:(CGRect)frame;

/**
 *  The title to display to inform the user of no content.
 */
@property (nonatomic, strong) NSString *title;

/**
 *  The message to display to inform the user why there is no content.
 */
@property (nonatomic, strong) NSString *message;

/**
 *  An icon to display about the missing content.
 */
@property (nonatomic, strong) UIImage *icon;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds withTitleString:(NSString *)titleString withMessageString:(NSString *)messageString withDependencyManager:(VDependencyManager *)dependencyManager;

@end
