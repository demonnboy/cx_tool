//
//  SHTry.h
//  SHUIPlan
//
//  Created by Demon on 2019/12/12.
//  Copyright © 2019 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHTry : NSObject

+ (void)try:(void (^)(void))stry catch:(void (^)(NSException *exception))scatch finally:(nullable void (^)(void))sfinally;

@end

NS_ASSUME_NONNULL_END
