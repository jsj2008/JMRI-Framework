//
//  JMRIReporter.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/8/2012.
//
//

#import "JMRIReporter.h"
#import "JMRIItem+Internal.h"

@implementation JMRIReporter

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeReporter];
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@", self.name]];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeReporter];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeReporter value:self.value];
}

- (void)writeToSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@ %@", self.name, self.value]];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeReporter value:self.value];
}

- (NSString *)type {
    return JMRITypeReporter;
}

@end
