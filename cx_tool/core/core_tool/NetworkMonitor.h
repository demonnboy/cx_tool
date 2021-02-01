//
//  NetworkMonitor.h
//  cx_tool
//
//  Created by Demon on 2021/2/1.
//  Copyright © 2021 Demon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkMonitor : NSObject

@property (nonatomic, copy) NSString *downLoadNetSpeed;
@property (nonatomic, copy) NSString *upLoadNetSpeed;

- (long long)getInterFaceBytes;

@end

NS_ASSUME_NONNULL_END
