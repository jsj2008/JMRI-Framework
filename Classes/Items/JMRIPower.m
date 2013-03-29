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

- (void)monitorWithXmlIOService {
    [self.service.xmlIOService readItem:JMRITypePower ofType:JMRITypePower initialValue:[[NSNumber numberWithInteger:self.state] stringValue]];
}

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:JMRITypePower ofType:JMRITypePower];
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[JMRITypePower uppercaseString]];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:JMRITypePower ofType:JMRITypePower];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:JMRITypePower ofType:JMRITypePower];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:JMRITypePower ofType:JMRITypePower state:self.state];
}

- (void)writeToSimpleService:(SimpleService *)service {
    switch (self.state) {
        case JMRIItemStateActive:
            [service send:@"POWER ON"];
            break;
        case JMRIItemStateInactive:
            [service send:@"POWER OFF"];
            break;
        default:
            break;
    }
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

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:JMRITypePower ofType:JMRITypePower value:self.value];
}

#pragma mark - Properties

- (Boolean)inverted {
    return NO;
}

- (NSString *)comment {
    return nil;
}

- (NSString *)name {
    return JMRITypePower;
}

- (NSString *)userName {
    return JMRITypePower;
}

- (NSString *)type {
    return JMRITypePower;
}

@end
