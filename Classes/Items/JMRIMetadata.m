//
//  JMRIMetadata.m
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "JMRIMetadata.h"
#import "JMRIItem+Internal.h"

@implementation JMRIMetadata

- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties {
    if ((self = [super initWithName:name withService:service withProperties:properties])) {
        _state = JMRIItemStateStateless;
        self.majorVersion = 0;
        self.minorVersion = 0;
        self.testVersion = 0;
    }
    return self;
}

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:self.type];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:self.type];
}

- (NSString *)type {
    return JMRITypeMetadata;
}

@end
