
//
//  OXMNativeAds.h
//  OpenX_iOS_SDK
//
//  Created 2/11/14
//  Copyright OpenX Technologies, Inc
//
//

#import <Foundation/Foundation.h>

@class OXMNativeAdData, OXMNativeAdRequest;

/** Native Ads object, which manages the process of loading and displaying of native format advertisements.
 This object is not currently threadsafe. Calling multiple loads on a single instance should be serialized.
 */

@interface OXMNativeAds : NSObject

/** Whether to use SSL with OpenX server. Default false.
 */
@property (nonatomic, assign) BOOL useSSL;

/** Access the native request to tell the server about the desired native attributes.
 */
@property (nonatomic, readonly) OXMNativeAdRequest* nativeRequest;


/** Initialize an OpenXNativeAds instance.
 @param domain The OpenX ad server domain
 @param nauid The OpenX native ad unit ID
 */
-(id) initWithDomain:(NSString*)domain nativeAdUnitID:(NSString*)nauid;

/** Load a native ad and handle the response.
 @param handler A block that takes an OXMNativeAdData and an NSError object. Only one of the 2 parameters will be non-nil.
 */
-(void) loadAdWithHandler:(void (^)(OXMNativeAdData* ad, NSError* error)) handler;



@end

