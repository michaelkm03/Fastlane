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
#define CEIL(a) ceil(a)
#else
#define CEIL(a) ceilf(a)
#endif

#endif
