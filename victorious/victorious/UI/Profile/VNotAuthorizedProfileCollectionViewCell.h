//
//  VNotLoggedInProfileCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/**
 *  A VNotAuthorizedProfileCollectionViewCell infroms the user
 *  that they are not currently logged in and provides a call
 *  to action button for them to do so.
 *
 *  Upon selecting this cell or tapping the call to action this
 *  cell uses the VLoginRequest protocol to send a request for 
 *  authorization up the responder chain.
 */
@interface VNotAuthorizedProfileCollectionViewCell : VBaseCollectionViewCell

@end
