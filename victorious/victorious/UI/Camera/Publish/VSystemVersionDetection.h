//
//  VSystemVersionDetection.h
//

#import <Foundation/Foundation.h>

/**
 Grabs the current system version number and parses the numbers between the dots
 */
@interface VSystemVersionDetection : NSObject

/**
 Returns the major version number (first integer in the version string)
 */
+ (NSInteger)majorVersionNumber;

/**
 Returns the minor version number (second integer in the version string)
 */
+ (NSInteger)minorVersionNumber;

/**
 Returns the patch number (third integer in the version string)
 */
+ (NSInteger)patchNumber;

@end
