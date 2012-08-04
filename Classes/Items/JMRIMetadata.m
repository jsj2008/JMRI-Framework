//
//  JMRIMetadata.m
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "JMRIMetadata.h"

@implementation JMRIMetadata

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    if ((self = [super initWithName:name withService:service])) {
        _state = JMRIItemStateStateless;
        self.majorVersion = 0;
        self.minorVersion = 0;
        self.testVersion = 0;
    }
    return self;
}

- (void)monitor {
    [self query];
    // don't actually monitor, since metadata is fixed
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    [service readItem:self.name ofType:self.type];
}

- (NSString *)type {
    return JMRITypeMetadata;
}

@end
