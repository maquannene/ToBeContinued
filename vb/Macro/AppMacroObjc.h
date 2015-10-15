//
//  AppMacroObjc.h
//  vb
//
//  Created by 马权 on 6/10/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#ifndef vb_AppMacroObjc_h
#define vb_AppMacroObjc_h

typedef void(^VoidBlock)(void);

static inline void cleanUpBlock(__strong VoidBlock *block) {
    (*block)();
}

#define onExit \
__strong VoidBlock block __attribute__((cleanup(cleanUpBlock), unused)) = ^

#endif
