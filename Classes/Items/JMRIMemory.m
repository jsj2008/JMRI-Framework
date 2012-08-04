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

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    [service writeItem:self.name ofType:self.type value:self.value];
}

- (NSString *)type {
    return JMRITypeMemory;
}

@end
