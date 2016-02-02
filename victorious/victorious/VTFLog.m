//
//  VTFLog.m
//  victorious
//
//  Created by Josh Hinman on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "TestFairy.h"
#import "VTFLog.h"

#if V_ENABLE_TESTFAIRY
void VTFLog(NSString *logMessage)
{
    TFLog(@"%@", logMessage);
}
#endif
