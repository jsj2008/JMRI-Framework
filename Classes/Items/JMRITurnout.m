//
//  JMRITurnout.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRITurnout.h"
#import "JMRIConstants.h"

@implementation JMRITurnout

- (void)monitorWithXmlIOService {
    [self.service readItem:self.name ofType:JMRITypeTurnout initialValue:[[NSNumber numberWithInteger:self.state] stringValue]];
}

- (void)readFromSimpleService {
    [self.service readItem:self.name ofType:[JMRITypeTurnout uppercaseString]];
}

- (void)readFromXmlIOService {
    [self.service readItem:self.name ofType:JMRITypeTurnout];
}

- (void)writeToSimpleService {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"THROWN";
            break;
        case JMRIItemStateInactive:
            state = @"CLOSED";
            break;                
        default:
            state = @"UNKNOWN";
            break;
    }
    [self.service writeItem:self.name ofType:JMRITypeTurnout value:state];
}

- (void)writeToWiThrottleService {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"T";
            break;
        case JMRIItemStateInactive:
            state = @"C";
            break;
        default:
            state = @"U";
            break;
    }
    [self.service writeItem:self.name ofType:JMRITypeTurnout value:state];
}

- (void)writeToXmlIOService {
    [self.service writeItem:self.name ofType:JMRITypeTurnout value:[[NSNumber numberWithInteger:self.state] stringValue]];
}

@end
