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

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeLight];
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"LIGHT %@", self.name]];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeLight state:self.state];
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
