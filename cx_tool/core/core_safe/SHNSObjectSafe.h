//
//  NSObjectSafe.h
//  NSObjectSafe
//
//  Created by jasenhuang on 15/12/29.
//  Copyright © 2015年 tencent. All rights reserved.
//

/**
 * Warn: NSObjectSafe must used in MRC, otherwise it will cause 
 * strange release error: [UIKeyboardLayoutStar release]: message sent to deallocated instance
 */

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

//! Project version number for NSObjectSafe.
FOUNDATION_EXPORT double NSObjectSafeVersionNumber;

//! Project version string for NSObjectSafe.
FOUNDATION_EXPORT const unsigned char NSObjectSafeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NSObjectSafe/PublicHeader.h>

FOUNDATION_EXPORT NSString *const NSSafeNotification;

@interface NSObject(Swizzle)

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;
- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;

@end

@interface NSObject (Safe)

+ (void)hookNotification;
+ (void)hookSignatureForSelector;

@end

@interface NSString (Safe)

+ (void)hookNSString;

@end

@interface NSMutableString (Safe)

+ (void)hookNSMutableString;

@end

@interface NSAttributedString (Safe)

+ (void)hookNSAttributedString;

@end

@interface NSMutableAttributedString (Safe)

+ (void)hookNSMutableAttributedString;

@end

@interface NSArray (Safe)

+ (void)hookNSArray;

@end

@interface NSMutableArray (Safe)

+ (void)hookNSMutableArray;

@end

@interface NSData (Safe)

+ (void)hookNSData;

@end

@interface NSMutableData (Safe)

+ (void)hookNSMutableData;

@end

@interface NSDictionary (Safe)

+ (void)hookNSDictionary;

@end

@interface NSMutableDictionary (Safe)

+ (void)hookNSMutableDictionary;

@end

@interface NSSet (Safe)

+ (void)hookNSSet;

@end

@interface NSMutableSet (Safe)

+ (void)hookNSMutableSet;

@end

@interface NSOrderedSet (Safe)

+ (void)hookNSOrderedSet;

@end

@interface NSMutableOrderedSet (Safe)

+ (void)hookNSMutableOrderedSet;

@end

@interface NSUserDefaults (Safe)

+ (void)hookNSUserDefaults;

@end

@interface NSCache (Safe)

+ (void)hookNSCache;

@end

@interface UIView (Safe)

+ (void)hookUIView;

@end
