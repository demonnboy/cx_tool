//
//  NSArray+Tool.h
//  cx_tool
//
//  Created by Demon on 2020/9/24.
//  Copyright © 2020 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHCollectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Tool) <SHCollectionProtocol>

@property (nonatomic, assign, readonly) BOOL isEmpty;

@end

@interface NSMutableArray (Tool) <SHCollectionProtocol>

@property (nonatomic, assign, readonly) BOOL isEmpty;

@end

NS_ASSUME_NONNULL_END
