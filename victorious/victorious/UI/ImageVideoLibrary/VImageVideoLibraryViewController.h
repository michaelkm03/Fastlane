//
//  VImageVideoLibraryViewController.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

@class VImageLibraryAlternateCaptureOption;

@interface VImageVideoLibraryViewController : UIViewController <VHasManagedDependencies>

/**
 *  An array of `VImageLibraryAlternateCaptureOption`s for providing the user 
 *  alternate options of media selection.
 */
@property (nonatomic, strong) NSArray *alternateCaptureOptions;

@end

#pragma mark - Alternate Options

/**
 *  A selection block for alternate capture options.
 */
typedef void (^VImageVideoLibraryAlternateCaptureSelection)();

/**
 *  A model object to pass to the image video library to allow the user to select other options.
 */
@interface VImageLibraryAlternateCaptureOption : NSObject

/**
 *  The designated initializer for creating alternate capture option objects. All parameters are required.
 *
 *  @param title The title of the alternate capture option. Note this should be localized prior to passing in here.
 *  @param icon An icon for the alternate capture option.
 *  @param selectionBlock A selection block that will be called up on selection of this alternate capture option.
 */
- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
            andSelectionBlock:(VImageVideoLibraryAlternateCaptureSelection)selectionBlock NS_DESIGNATED_INITIALIZER;

/**
 *  The title passed in the designated initializer.
 */
@property (nonatomic, readonly) NSString *title;

/**
 *  The icon passed in the designated initializer.
 */
@property (nonatomic, readonly) UIImage *icon;

@end
