//
//  JMRITurnout.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRITurnout.h"
#import "JMRIItem+Internal.h"

@implementation JMRITurnout

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"TURNOUT %@", self.name]];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:JMRITypeTurnout];
}

- (void)writeToSimpleService:(SimpleService *)service {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"THROWN";
            break;
        case JMRIItemStateInactive:
            state = @"CLOSED";
            break;                
        default:
            return; // state is invalid so don't send it
            break;
    }
    [service send:[NSString stringWithFormat:@"TURNOUT %@ %@", self.name, state]];
}

- (void)writeToWiThrottleService:(WiThrottleService *)service {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"T";
            break;
        case JMRIItemStateInactive:
            state = @"C";
            break;
        default:
            return; // state is invalid so don't send it
            break;
    }
    [service send:[NSString stringWithFormat:@"PTA%@%@", state, self.name]];
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:JMRITypeTurnout value:[[NSNumber numberWithInteger:self.state] stringValue]];
}

@end
