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

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    if (([super initWithName:name withService:service] != nil)) {
        _state = JMRIItemStateStateless;
    }
    return self;
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@", self.name]];
}

- (void)writeToSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@ %@", self.name, self.value]];
}

- (NSString *)type {
    return JMRITypeReporter;
}

@end
