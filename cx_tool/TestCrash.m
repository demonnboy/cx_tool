//
//  TestCrash.m
//  cx_tool
//
//  Created by Demon on 2020/8/19.
//  Copyright © 2020 Demon. All rights reserved.
//

#import "TestCrash.h"

@implementation TestCrash

- (void)unrecognizedSelector {
    
}

- (void)arrayCrash {
//    NSArray* array = @"hello";
//    NSLog(@"%@", [array objectAtIndex:1]);
//
//    array = [NSArray arrayWithObjects:@1, @2, nil];//__NSArrayI
//    [array subarrayWithRange:NSMakeRange(0, 1)];
//
//    array = [NSArray arrayWithObjects:nil];//__NSArray0
//    [array subarrayWithRange:NSMakeRange(2, 2)];
//
//    array = [NSArray arrayWithObjects:@1, nil];//__NSSingleObjectArrayI
//    NSLog(@"%@", array[2]);
//    [array objectAtIndex:4];
//
//    array = [NSArray arrayWithObjects:@1, @2, nil];//__NSArrayI
//    NSLog(@"%@", array[3]);
//    [array objectAtIndex:4];
//
//    NSMutableArray* marray = [NSMutableArray arrayWithObjects:@1, @2, nil];//__NSArrayM
//    marray = [marray copy];
//    [marray insertObject:@3 atIndex:3];
//    NSLog(@"%@", marray[3]);
//    [marray removeObjectAtIndex:3];
//    
//    NSArray* item = nil;
//    NSArray * items = @[@"a",@"b", item ,@"c"];
}

- (void)dictionaryCrash {
//    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:nil];//__NSDictionary0
//    [dict objectForKey:nil];
//
//    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a",@"1", nil];//__NSSingleEntryDictionaryI
//    [dict objectForKey:nil];
//
//    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a",@"1",@"b",@"2", nil];//__NSDictionaryI
//    [dict objectForKey:nil];
//
//    NSMutableDictionary* mdict = [[NSMutableDictionary alloc] initWithCapacity:3];
//    [mdict setObject:@1 forKey:@1];
//    [mdict setObject:nil forKey:@1];
//    [mdict setObject:@1 forKey:@1];
//    [mdict removeObjectForKey:nil];
//    mdict[@1] = nil;
//    [NSMutableArray arrayWithArray:[mdict allValues]];
}

- (void)stringCrash {
    NSString* string = @"12345";
    [string substringFromIndex:6];
    [string substringToIndex:6];
    [string substringWithRange:NSMakeRange(0, 6)];
    [string substringWithRange:NSMakeRange(-1, -1)];
    [string substringWithRange:NSMakeRange(1, -1)];
    [string substringWithRange:NSMakeRange(-1, 1)];
    
    string = [NSString stringWithUTF8String:"1"];
    [string substringFromIndex:600];
    [string substringToIndex:600];
    [string substringWithRange:NSMakeRange(100, 6)];
    
    //__NSCFString
    string = [NSMutableString stringWithUTF8String:"1"];
    [string substringFromIndex:600];
    [string substringToIndex:600];
    [string substringWithRange:NSMakeRange(100, 6)];
    
    NSMutableString* mstring = [NSMutableString string];
    [mstring appendString:@"12345"];
    NSLog(@"%@", [mstring substringToIndex:10]);
    NSLog(@"%@", [mstring substringWithRange:NSMakeRange(3, 10)]);
}

@end
