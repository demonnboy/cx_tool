//
//  NSArray+Tool.m
//  cx_tool
//
//  Created by Demon on 2020/9/24.
//  Copyright © 2020 Demon. All rights reserved.
//

#import "NSArray+Tool.h"

@implementation NSArray (Tool)

- (BOOL)isEmpty {
    if (self && self.count > 0) {
        return YES;
    }
    return NO;
}

@end

@implementation NSMutableArray (Tool)

- (BOOL)isEmpty {
    if (self && self.count > 0) {
        return YES;
    }
    return NO;
}

@end
