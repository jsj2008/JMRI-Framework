//
//  JMRISensor.m
//  JMRI-Framework
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

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeSensor];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor state:self.state];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeSensor state:self.state];
}

- (NSString *)type {
    return JMRITypeSensor;
}

@end
