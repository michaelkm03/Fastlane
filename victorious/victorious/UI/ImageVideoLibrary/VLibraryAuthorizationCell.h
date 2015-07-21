//
//  VLibraryAuthorizationCell.h
//  victorious
//
//  Created by Michael Sena on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/**
 *  VLibraryAuthorizationCell provides interface when the user has not granted 
 *  authorization to the image library yet.
 */
@interface VLibraryAuthorizationCell : VBaseCollectionViewCell

// Strings
@property (nonatomic, copy) NSString *promptText;
@property (nonatomic, copy) NSString *callToActionText;

// Fonts
@property (nonatomic, strong) UIFont *promptFont;
@property (nonatomic, strong) UIFont *callToActionFont;

// Colors
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, strong) UIColor *callToActionColor;

@end
