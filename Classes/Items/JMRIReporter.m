//
//  JMRIReporter.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/8/2012.
//
//

#import "JMRIReporter.h"
#import "JMRIReporter+Internal.h"
#import "JMRIItem+Internal.h"

@implementation JMRIReporter
@synthesize report = _report;

- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties {
    if ((self = [super initWithName:name withService:service withProperties:properties])) {
        if (properties[JMRIItemReport]) {
            _report = properties[JMRIItemReport];
        }
        if (properties[JMRIItemLastReport]) {
            _lastReport = properties[JMRIItemLastReport];
        }
    }
    return self;
}

- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeReporter];
}

- (void)queryFromWebService:(WebService *)service {
    [service readItem:self.name ofType:JMRITypeReporter];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeReporter withProperties:@{JMRIItemReport: self.report}];
}

- (void)writeToWebService:(WebService *)service {
    [service writeItem:self.name ofType:JMRITypeReporter withProperties:@{JMRIItemReport: self.report}];
}

- (NSString *)type {
    return JMRITypeReporter;
}

- (void)setReport:(NSString *)report {
    [self setReport:report withLastReport:self.report];
}

- (NSString *)report {
    return [_report copy];
}

- (void)setValue:(NSString *)value updateService:(Boolean)update {
    [self setReport:value withLastReport:self.report updateService:update];
}

- (NSString *)value {
    return self.report;
}

- (void)setReport:(NSString *)report withLastReport:(NSString *)lastReport {
    [self setReport:report withLastReport:lastReport updateService:YES];
}

- (void)setReport:(NSString *)report withLastReport:(NSString *)lastReport updateService:(Boolean)update {
    if (![_report isEqualToString:report]) {
        _report = report;
        if (update) {
            if (!_report) {
                [self query];
            } else {
                [self write];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationStateChange object:self];
    }
}

@end
