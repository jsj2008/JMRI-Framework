//
//  JMRISignalHead.m
//  JMRI-Framework
//
//  Created by Randall Wood on 11/8/2012.
//
//

#import "JMRISignalHead.h"
#import "JMRIItem+Internal.h"

@implementation JMRISignalHead

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeSignalHead];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeSignalHead];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeSignalHead state:self.state];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeSignalHead state:self.state];
}

@end
