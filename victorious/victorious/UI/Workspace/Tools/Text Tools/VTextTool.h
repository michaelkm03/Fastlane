//
//  VTextTool.h
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

/**
 *  VTextWorkspaceTool manages selection among several different text tool types and provides an inspector picker. It also manages a container view controller that the different text tools place their UI in to. During rendering it renders an image of the active text tool's text and the composites that with the input image.
 *
 *  NOTE: VTextTool expects it's picker to be of type VTickerPickerViewController.
 *
 */
@interface VTextTool : NSObject <VHasManagedDependancies, VWorkspaceTool>

@property (nonatomic, readonly) NSString *embeddedText; ///< The embedded text if any.
@property (nonatomic, readonly) NSString *textStyleTitle; ///< The selected text style if any.

@end
