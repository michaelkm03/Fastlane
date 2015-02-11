//
//  VPurchaseDebugSettings.h
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

/**
 In-App Purchasing through StoreKit doens't work in the simulator, so when the simulator is
 the target, classes related to purchasing will skip any use of StoreKit and continue as if valid data
 was returned from the App Store.  You can also use FORCE_SIMULATE_STOREKIT to do the same
 thing on a device.  SIMULATE_STOREKIT must be set to 1 for any of the other error-specific
 settings below to work.
 */

#define FORCE_SIMULATE_STOREKIT             0

#define SIMULATE_STOREKIT                   FORCE_SIMULATE_STOREKIT || TARGET_IPHONE_SIMULATOR

/**
 When SIMULATE_STOREKIT is defined and set to 1, all simulated responses will be successful,
 i.e. they return valid data and call any success callbacks provided.  To trigger a specific
 error, use these macros below.
 */

#define SIMULATE_PURCHASE_ERROR             0

#define SIMULATE_RESTORE_PURCHASE_ERROR     0

// Failed products are treated as if they don't exist, so this effectively hides any purchaseable items
#define SIMULATE_FETCH_PRODUCTS_ERROR       0


// The amount of time to wait to simulate the delay of a network response
#define SIMULATION_DELAY                    1.0f

// The number of products to return when simulating restoring purchases.
#define SIMULATED_RESTORED_PURCHASE_COUNT   3

// A dummy product identifier to stand in for what StoreKit ususally returns
#define SIMULATED_PRODUCT_IDENTIFIER        @"com.getvictorious.eatyourkimchi.ballistic.meemers"


#if FORCE_SIMULATE_STOREKIT || SIMULATE_PURCHASE_ERROR || SIMULATE_FETCH_PRODUCTS_ERROR || SIMULATE_RESTORE_PURCHASE_ERROR
#warning VPurchaseManager is simulating one or more failed StoreKit interactions
#endif
