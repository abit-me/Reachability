//
//  Reachability.m
//  iCamera
//
//  Created by A on 2017/11/29.
//  Copyright © 2017年 A. All rights reserved.
//

#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation Reachability {
    
    SCNetworkReachabilityRef reachability;
    NetStatusChangedCallback changedCallback;
}

void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info)
{
    Reachability * noteObject = (__bridge Reachability *)info;
    
    NetStatus netStatus = [noteObject netStatusWithFlags:flags];
    if (noteObject->changedCallback) noteObject->changedCallback(netStatus);
}

- (instancetype)initWithHost:(NSString *)host {
    
    if (self = [super init]) {
        reachability = SCNetworkReachabilityCreateWithName(NULL, host.UTF8String);
        if (!reachability) {
            NSLog(@"Reachability init error: SCNetworkReachabilityCreateWithName failed");
            return nil;
        }
    }
    return self;
}

- (NetStatus)netStatusWithFlags:(SCNetworkReachabilityFlags)flags {
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        // NSLog(@"NotReachable");
        return NetStatusNotReachable;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
        // NSLog(@"ReachableViaWiFi");
        return NetStatusReachable;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // and no [user] intervention is needed...
            // NSLog(@"ReachableViaWiFi");
            return NetStatusReachable;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // but WWAN connections are OK if the calling application is using the CFNetwork APIs
        // NSLog(@"ReachableViaWWAN");
        return NetStatusReachable;
    }
    
    return NetStatusUnknown;
}

- (NetStatus)currentNetStatus {
    
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
        return [self netStatusWithFlags:flags];
    }
    return NetStatusUnknown;
}

- (void)detectNetStatusWithCallback:(NetStatusChangedCallback)callback {
    
    changedCallback = callback;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context))
    {
        if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            NSLog(@"Reachability detectNetStatusWithNotificationName failed");
        }
    }
}

@end
