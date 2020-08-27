//
//  SHCrashProtectorManager.h
//  cx_tool
//
//  Created by Demon on 2020/8/20.
//  Copyright © 2020 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SHCrashProtector) {
    SHCrashProtectorNone = 0,
    SHCrashProtectorAll = 1,                        // 上报code码
    SHCrashProtectorArray = 1 << 1,                 // 6001
    SHCrashProtectorDictionary = 1 << 2,            // 6002
    SHCrashProtectorString = 1 << 3,                // 6003
    SHCrashProtectorAttributedString = 1 << 4,      // 6004
    SHCrashProtectorData = 1 << 5,                  // 6005
    SHCrashProtectorSet = 1 << 6,                   // 6006
    SHCrashProtectorUserDefaults = 1 << 7,          // 6007
    SHCrashProtectorCache = 1 << 8,                 // 6008
    SHCrashProtectorSelector = 1 << 9,              // 6009
    SHCrashProtectorLayoutOnMainThread = 1 << 10,   // 6010
    SHCrashProtectorNotification = 1 << 11,         // 6011
};
NS_ASSUME_NONNULL_BEGIN

@interface SHCrashProtectorManager : NSObject

+ (void)start:(SHCrashProtector)type;

@end

NS_ASSUME_NONNULL_END
