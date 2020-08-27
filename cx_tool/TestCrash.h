//
//  TestCrash.h
//  cx_tool
//
//  Created by Demon on 2020/8/19.
//  Copyright © 2020 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestCrash : NSObject

- (void)unrecognizedSelector;
- (void)arrayCrash;
- (void)dictionaryCrash;
- (void)stringCrash;

@end

NS_ASSUME_NONNULL_END
