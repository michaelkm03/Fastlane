//
//  VTextTypeTool.h
//  victorious
//
//  Created by Michael Sena on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

typedef NS_ENUM(NSInteger, VTextTypeVerticalAlignment)
{
    VTextTypeVerticalAlignmentCenter, ///< Text should be aligned center (like secret)
    VTextTypeVerticalAlignmentBottomUp, ///< Text should be aligned to the bottom and grow up
};

/**
 *   VTextTypeTool represents a type of a text tool. Such as meme, quote, etc.
 */
@interface VTextTypeTool : NSObject <VHasManagedDependancies, VWorkspaceTool>

@property (nonatomic, readonly) VTextTypeVerticalAlignment verticalAlignment; ///< Should this be center or bottom aligned
@property (nonatomic, readonly) NSDictionary *attributes; ///< They attributes for use in NSAttributedStrings
@property (nonatomic, readonly) UIColor *dimmingBackgroundColor; ///< A dimming background color, if any
@property (nonatomic, readonly) NSString *placeholderText; ///< Placeholder text for when the user has yet to enter any text
@property (nonatomic, readonly) BOOL shouldForceUppercase; ///< If a text tool 

@end
