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

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeLight];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeLight state:self.state];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeLight state:self.state];
}

- (NSString *)type {
    return JMRITypeLight;
}

@end
