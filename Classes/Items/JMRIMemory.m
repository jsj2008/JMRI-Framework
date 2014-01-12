//
//  JMRIMemory.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/8/2012.
//
//

#import "JMRIMemory.h"
#import "JMRIItem+Internal.h"

@implementation JMRIMemory

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:self.type value:self.value];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:self.type value:self.value];
}

- (NSString *)type {
    return JMRITypeMemory;
}

@end
