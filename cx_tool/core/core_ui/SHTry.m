//
//  SHTry.m
//  SHUIPlan
//
//  Created by Demon on 2019/12/12.
//  Copyright © 2019 Demon. All rights reserved.
//

#import "SHTry.h"

@implementation SHTry

+ (void)try:(void (^)(void))stry catch:(void (^)(NSException *exception))scatch finally:(nullable void (^)(void))sfinally {
    @try {
        if (stry) { stry(); }
    } @catch (NSException *exception) {
        if (scatch) { scatch(exception); }
    } @finally {
        if (sfinally) { sfinally(); }
    }
}

@end
