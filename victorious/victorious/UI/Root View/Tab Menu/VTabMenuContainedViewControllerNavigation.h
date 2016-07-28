//
//  VTabMenuContainedViewControllerNavigation.h
//  victorious
//
//  Created by Michael Sena on 5/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
*  ViewControllers that may be contained inside of a VTabMenuViewController
*  should conform to this protocol to be notified of reselection from the tab menu.
*/
@protocol VTabMenuContainedViewControllerNavigation <NSObject>

/**
 *  Informs the conformer that the user has reselected the container tab from the
 *  tab bar. Will only be called if this viewcontroller is already the currently
 *  selected viewcontroller. Confromers should implement this method for pop-to-root
 *  functionality.
 */
- (void)reselected;

@end
