//
//  VContentTextCell.h
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentCell.h"

/**
 A collection view cell used to display a text post in `VNewContentViewConroller`.
 */
@interface VContentTextCell : VContentCell

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Sets the text content and color from the text post to display as created by the user.
 */
- (void)setTextContent:(NSString *)text
       backgroundColor:(UIColor *)backgroundColor
    backgroundImageURL:(NSURL *)backgroundImageURL;

@end
