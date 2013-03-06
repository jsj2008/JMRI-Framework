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

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    if ((self = [super initWithName:name withService:service])) {
        _state = JMRIItemStateStateless;
    }
    return self;
}

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:self.type value:self.value];
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:self.type value:self.value];
}

- (NSString *)type {
    return JMRITypeMemory;
}

@end
