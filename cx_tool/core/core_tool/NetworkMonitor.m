//
//  NetworkMonitor.m
//  cx_tool
//
//  Created by Demon on 2021/2/1.
//  Copyright © 2021 Demon. All rights reserved.
//

#import "NetworkMonitor.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@interface NetworkMonitor () {
    uint32_t _iBytes;
    uint32_t _oBytes;
}

@end

@implementation NetworkMonitor

- (long long)getInterFaceBytes {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    uint32_t allFlow = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family) {
            continue;
        }
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) {
            continue;
        }
        if (ifa->ifa_data == 0) {
            continue;
        }
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + iBytes;
        }
    }
    freeifaddrs(ifa_list);
    
    if (_iBytes != 0) {
        self.downLoadNetSpeed = [[self stringWithbytes:iBytes - _iBytes] stringByAppendingFormat:@"/s"];
        NSLog(@"%@", self.downLoadNetSpeed);
    }
    _iBytes = iBytes;
    
    if (_oBytes != 0) {
        self.upLoadNetSpeed = [[self stringWithbytes:oBytes - _oBytes] stringByAppendingFormat:@"/s"];
        NSLog(@"%@", self.upLoadNetSpeed);
    }
    _oBytes = oBytes;
    
    return allFlow;
}

- (NSString *)stringWithbytes:(int)bytes {
    if (bytes < 1024) { // B
        return [NSString stringWithFormat:@"%dB", bytes];
    } else if (bytes >= 1024 && bytes < 1024 * 1024) { // KB
        return [NSString stringWithFormat:@"%.0fKB", (double)bytes / 1024];
    } else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) { // MB
        return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
    } else { // GB
        return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

@end
