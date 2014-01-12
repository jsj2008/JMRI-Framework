//
//  JMRIPower.m
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIPower.h"
#import "JMRIItem+Internal.h"

@implementation JMRIPower

#pragma mark - Operations

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:JMRITypePower ofType:JMRITypePower];
}

- (void)queryFromWebService:(WebService *)service {
    [service list:JMRITypePower]; // treat specially since the power indicator has no name
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:JMRITypePower ofType:JMRITypePower state:self.state];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:JMRITypePower ofType:JMRITypePower state:self.state];
}

- (void)writeToWiThrottleService:(WiThrottleService *)service {
    switch (self.state) {
        case JMRIItemStateActive:
            [service send:@"PPA1"];
            break;
        case JMRIItemStateInactive:
            [service send:@"PPA0"];
            break;
        default:
            break;
    }
}

#pragma mark - Properties

- (Boolean)inverted {
    return NO;
}

- (NSString *)name {
    return JMRITypePower;
}

- (NSString *)type {
    return JMRITypePower;
}

@end
