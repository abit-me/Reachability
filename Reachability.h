//
//  Reachability.h
//  iCamera
//
//  Created by A on 2017/11/29.
//  Copyright © 2017年 A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NetStatusNotReachable,
    NetStatusReachable,
    NetStatusUnknown,
} NetStatus;

typedef void(^NetStatusChangedCallback)(NetStatus status);

@interface Reachability : NSObject
- (instancetype)initWithHost:(NSString *)host;
- (NetStatus)currentNetStatus;
- (void)detectNetStatusWithCallback:(NetStatusChangedCallback)callback;
@end
