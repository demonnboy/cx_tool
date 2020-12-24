//
//  SHTestViewController.m
//  cx_tool
//
//  Created by Demon on 2020/12/11.
//  Copyright © 2020 Demon. All rights reserved.
//

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

#import "SHTestViewController.h"

@interface SHTestViewController ()

@property (nonatomic, copy) void (^block)(void);

@end

@implementation SHTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak SHTestViewController *weakSelf = self;
    self.block = ^{
        __strong SHTestViewController *strongSelf = weakSelf;
        NSLog(@"%@", strongSelf);
    };
    [self completion:^{
        self.block();
    }];
}

- (void)completion:(void (^)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}

- (void)dealloc {
    NSLog(@"释放了");
}


@end
