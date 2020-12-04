//
//  NSDictionary+Tool.m
//  cx_tool
//
//  Created by Demon on 2020/9/24.
//  Copyright © 2020 Demon. All rights reserved.
//

#import "NSDictionary+Tool.h"

@implementation NSDictionary (Tool)

- (BOOL)isEmpty {
    if (self && self.allKeys.count > 0) {
        return  NO;
    }
    return YES;
}

@end

@implementation NSMutableDictionary (Tool)

- (BOOL)isEmpty {
    if (self && self.allKeys.count > 0) {
        return  NO;
    }
    return YES;
}

@end
