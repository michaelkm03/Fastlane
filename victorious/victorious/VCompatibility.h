//
//  VCompatibility.h
//  victorious
//
//  Created by Michael Sena on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#ifndef victorious_VCompatibility_h
#define victorious_VCompatibility_h

#ifdef __LP64__
#define VCEIL(a) ceil(a)
#else
#define VCEIL(a) ceilf(a)
#endif

#ifdef __LP64__
#define VFLOOR(a) floor(a)
#else
#define VFLOOR(B) floorf(B)
#endif

#if __LP64__
#define VROUND(x) round(x)
#else
#define VROUND(x) roundf(x)
#endif

#if CGFLOAT_IS_DOUBLE
#define VCGFLOAT_VALUE doubleValue
#else
#define VCGFLOAT_VALUE floatValue
#endif

#endif
