//
//  SHCrashProtectorManager.m
//  cx_tool
//
//  Created by Demon on 2020/8/20.
//  Copyright © 2020 Demon. All rights reserved.
//

#import "SHCrashProtectorManager.h"
#import "SHNSObjectSafe.h"

@implementation SHCrashProtectorManager

+ (void)start:(SHCrashProtector)type {
    if (type & SHCrashProtectorNone) { return; }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SHCrashProtector tt = type;
        if (type & SHCrashProtectorAll) {
            tt = (SHCrashProtectorArray | SHCrashProtectorDictionary | SHCrashProtectorString | SHCrashProtectorAttributedString | SHCrashProtectorData | SHCrashProtectorSet | SHCrashProtectorUserDefaults | SHCrashProtectorCache | SHCrashProtectorSelector | SHCrashProtectorLayoutOnMainThread);
        }
        if (tt & SHCrashProtectorSelector) {
            [NSObject hookSignatureForSelector];
        }
        if (tt & SHCrashProtectorArray) {
            [NSArray hookNSArray];
            [NSMutableArray hookNSMutableArray];
        }
        if (tt & SHCrashProtectorDictionary) {
            [NSDictionary hookNSDictionary];
            [NSMutableDictionary hookNSMutableDictionary];
        }
        if (tt & SHCrashProtectorString) {
            [NSString hookNSString];
            [NSMutableString hookNSMutableString];
        }
        if (tt & SHCrashProtectorAttributedString) {
            [NSAttributedString hookNSAttributedString];
            [NSMutableAttributedString hookNSMutableAttributedString];
        }
        if (tt & SHCrashProtectorData) {
            [NSData hookNSData];
            [NSMutableData hookNSMutableData];
        }
        if (tt & SHCrashProtectorSet) {
            [NSSet hookNSSet];
            [NSMutableSet hookNSMutableSet];
            [NSOrderedSet hookNSOrderedSet];
            [NSMutableOrderedSet hookNSMutableOrderedSet];
        }
        if (tt & SHCrashProtectorUserDefaults) {
            [NSUserDefaults hookNSUserDefaults];
            
        }
        if (tt & SHCrashProtectorCache) {
            [NSCache hookNSCache];
        }
        if (tt & SHCrashProtectorLayoutOnMainThread) {
            [UIView hookUIView];
        }
        if (tt & SHCrashProtectorNotification) {
            [NSObject hookNotification];
        }
    });
}

@end
