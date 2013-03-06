//
//  JMRIRoute.m
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "JMRIRoute.h"
#import "JMRIItem+Internal.h"

@implementation JMRIRoute

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeRoute];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:JMRITypeRoute];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeRoute state:self.state];
}

// note that WiThrottleService can only toggle the route state, but cannot set the route state
- (void)writeToWiThrottleService:(WiThrottleService *)service {
    [service send:[NSString stringWithFormat:@"PRA2%@", self.name]];
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:JMRITypeRoute value:self.value];
}

- (NSString *)type {
    return JMRITypeRoute;
}

@end
