//
//  VMultiplePickerSelection.h
//  victorious
//
//  Created by Patrick Lynch on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMultiplePickerSelection : NSObject

- (void)resetSelectedIndexPaths;

- (void)indexPathWasSelected:(NSIndexPath *)indexPath;

- (void)indexPathWasDeselected:(NSIndexPath *)indexPath;

- (BOOL)isIndexPathSelected:(NSIndexPath *)indexPath;

@end
