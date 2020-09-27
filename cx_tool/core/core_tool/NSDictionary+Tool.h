//
//  NSDictionary+Tool.h
//  cx_tool
//
//  Created by Demon on 2020/9/24.
//  Copyright © 2020 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHCollectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Tool) <SHCollectionProtocol>

@property (nonatomic, assign, readonly) BOOL isEmpty;

@end

@interface NSMutableDictionary (Tool) <SHCollectionProtocol>

@property (nonatomic, assign, readonly) BOOL isEmpty;

@end

NS_ASSUME_NONNULL_END
