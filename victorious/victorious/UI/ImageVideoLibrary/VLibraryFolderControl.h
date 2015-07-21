//
//  VLibraryFolderControl.h
//  victorious
//
//  Created by Michael Sena on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Sends standard UIControlEvents. Use UIControlEventTouchUpInside to be notified of selection.
 */
@interface VLibraryFolderControl : UIControl

/**
 *  Use this to grab an instance of VLibraryFolderControl.
 */
+ (instancetype)newFolderControl;

/**
 *  The title to use in the title label.
 */
@property (nonatomic, copy) NSAttributedString *attributedTitle;

/**
 *  The subtitle to use in the subtitle label.
 */
@property (nonatomic, copy) NSAttributedString *attributedSubtitle;

@end
