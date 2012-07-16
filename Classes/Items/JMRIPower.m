//
//  JMRIPower.m
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIPower.h"

@implementation JMRIPower

#pragma mark - Operations

- (void)readFromSimpleService {
    [self.service readItem:nil ofType:[JMRITypePower uppercaseString]];
}

- (void)readFromXmlIOService {
    [self.service readItem:JMRITypePower ofType:JMRITypePower];
}

- (void)writeToSimpleService {
    switch (self.state) {
        case JMRIItemStateActive:
            [self.service writeItem:nil ofType:[JMRITypePower uppercaseString] value:@"ON"];
            break;
        case JMRIItemStateInactive:
            [self.service writeItem:nil ofType:[JMRITypePower uppercaseString] value:@"OFF"];
            break;
        default:
            break;
    }
}

- (void)writeToWiThrottleService {
    switch (self.state) {
        case JMRIItemStateActive:
            [self.service writeItem:nil ofType:@"PPA" value:@"1"];
            break;
        case JMRIItemStateInactive:
            [self.service writeItem:nil ofType:@"PPA" value:@"0"];
            break;
        default:
            break;
    }
}

- (void)writeToXmlIOService {
    [self.service writeItem:JMRITypePower ofType:JMRITypePower value:[[NSNumber numberWithInteger:self.state] stringValue]];
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

@end
