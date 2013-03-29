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

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeSensor];
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"SENSOR %@", self.name]];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeSensor];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:JMRITypeSensor];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor state:self.state];
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

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor state:self.state];
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor value:self.value];
}

- (NSString *)type {
    return JMRITypeSensor;
}

@end
