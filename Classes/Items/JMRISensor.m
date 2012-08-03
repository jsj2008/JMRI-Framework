//
//  JMRISensor.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/8/2012.
//
//

#import "JMRISensor.h"
#import "JMRIItem+Internal.h"

@implementation JMRISensor

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"SENSOR %@", self.name]];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:JMRITypeSensor];
}

- (void)writeToSimpleService:(SimpleService *)service {
    NSString* state;
    switch (self.state) {
        case JMRIItemStateActive:
            state = @"ACTIVE";
            break;
        case JMRIItemStateInactive:
            state = @"INACTIVE";
            break;
        default:
            return; // state is invalid so don't send it
            break;
    }
    [service send:[NSString stringWithFormat:@"SENSOR %@ %@", self.name, state]];
}

- (void)write {
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self writeToSimpleService:self.service.simpleService];
    } else if (self.service.hasWebService && self.service.useXmlIOService) {
        [self writeToXmlIOService:self.service.webService];
    }
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor value:[[NSNumber numberWithInteger:self.state] stringValue]];
}

- (NSString *)type {
    return JMRITypeSensor;
}

@end
