//
//  OXMNativeAdRequest.h
//  OpenX_iOS_SDK
//
//  Created by Julian Pellico on 3/4/14.
//
//

#import "OXMAdRequest.h"

@class OXMGlobal;

typedef enum {
    OXMNativeTypeInFeed,
    OXMNativeTypePaidSearch,
    OXMNativeTypeRecommendation,
    OXMNativeTypePromotedListing,
    OXMNativeTypeInAd,
    OXMNativeTypeCustom
} OXMNativeAdType;

typedef enum {
    OXMNativeFieldTitle      = 1 << 0,
    OXMNativeFieldBody       = 1 << 1,
    OXMNativeFieldClickURL   = 1 << 2,
    OXMNativeFieldImprURL    = 1 << 3,
    OXMNativeFieldImageURL   = 1 << 4,
    OXMNativeFieldAppStoreURL= 1 << 5,
    OXMNativeFieldVideoURL   = 1 << 6,
    OXMNativeFieldAudioURL   = 1 << 7,
} OXMNativeAdFields;


/** Use this class to set configuration for native ad units. Access the nativeRequest property of OXMNativeAds.
 */

@interface OXMNativeAdRequest : OXMAdRequest

/** Set the use case for the native ad. Refer to the help pages about which type is appropriate. */
-(void) setNativeType:(OXMNativeAdType)type;

/** Set the size of the desired small icon, in device pixels. Usually you will double your values for Retina. */
-(void) setDesiredIconSize:(CGSize)size;

/** Set the size of the desired main image, in device pixels. Usually you will double your values for Retina. */
-(void) setDesiredImageSize:(CGSize)size;

/** Set the maximum text length you wish to show.
 
 You may wish to check the text received in the ad to ensure it is an appropriate length.
 */
-(void) setMaximumTextLength:(uint32_t)length;

/** Set the required native fields by using the OR '|' operator with OXMNativeFields constants.
 */
-(void) setRequiredFields:(OXMNativeAdFields)fields;

/** The sequence number is the ad number on the current page, starting with 1.
 
 Set the sequence number when you display more than one ad on a page.
 */
-(void) setSequenceNumber:(uint32_t)seq;

@end
