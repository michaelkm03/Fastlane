//
//  VPurchaseDebugSettings.h
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#define FORCE_SIMULATE_STOREKIT             0
#define SIMULATE_STOREKIT                   FORCE_SIMULATE_STOREKIT || TARGET_IPHONE_SIMULATOR
#define SIMULATE_PURCHASE_ERROR             0
#define SIMULATE_FETCH_PRODUCTS_ERROR       0
#define SIMULATE_RESTORE_PURCHASE_ERROR     0
#define SIMULATION_DELAY                    1.0f
#define SIMULATED_RESTORED_PURCHASE_COUNT   0
#define SIMULATED_PRODUCT_IDENTIFIER        @"test.test.test"

#if FORCE_SIMULATE_STOREKIT || SIMULATE_NO_RESTORED_PRODUCTS || SIMULATE_PURCHASE_ERROR || SIMULATE_FETCH_PRODUCTS_ERROR || SIMULATE_RESTORE_PURCHASE_ERROR
#warning VPurchaseManager is simulating one or more failed StoreKit interactions
#endif
