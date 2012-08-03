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

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@", self.name]];
}

- (void)writeToSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"REPORTER %@ %@", self.name, self.report]];
}

- (NSString *)type {
    return JMRITypeReporter;
}

- (void)setReport:(NSString *)report {
    [self setReport:report updateService:YES];
}

- (NSString *)report {
    return _report;
}

- (void)setReport:(NSString *)report updateService:(Boolean)update {
    if (_report != report) {
        _report = report;
        if ([_report isEqualToString:@""]) {
            _report = nil;
        }
        if (update) {
            if (!_report) {
                [self query];
            } else {
                [self write];
            }
        }
        if ([self.delegate respondsToSelector:@selector(item:didGetReport:)]) {
            [self.delegate item:self didGetReport:_report];
        }
    }
}

@end
