//
//  JMRILight.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/8/2012.
//
//

#import "JMRILight.h"
#import "JMRIItem+Internal.h"

@implementation JMRILight

#pragma mark - Operations

// Lights are only supported by the SimpleService
- (void)query {
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self queryFromSimpleService:self.service.simpleService];
    }
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"LIGHT %@", self.name]];
}

// Lights are only supported by the SimpleService
- (void)write {
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self writeToSimpleService:self.service.simpleService];
    }
}

- (void)writeToSimpleService:(SimpleService *)service {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"ON";
            break;
        case JMRIItemStateInactive:
            state = @"OFF";
            break;
        default:
            return; // state is invalid so don't send it
            break;
    }
    [service send:[NSString stringWithFormat:@"LIGHT %@ %@", self.name, state]];
}

- (NSString *)type {
    return JMRITypeLight;
}

@end
