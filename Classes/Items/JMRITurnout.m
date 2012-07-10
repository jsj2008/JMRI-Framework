//
//  JMRITurnout.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRITurnout.h"

@implementation JMRITurnout

- (void)readState {
    [self.service readItem:self.name ofType:JMRITypeTurnout];
}

- (void)writeState {
    NSString* state;
    if ([self.service isKindOfClass:[XMLIOService class]]) {
        state = [[NSNumber numberWithInteger:self.state] stringValue];
    } else if ([self.service isKindOfClass:[SimpleService class]]) {
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
    } else {
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
    }
    [self.service writeItem:self.name ofType:JMRITypeTurnout value:state];
}

@end
