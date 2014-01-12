//
//  JMRIItem+Internal.h
//  JMRI Framework
//
//  Created by Randall Wood on 20/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"
#import "JsonService.h"
#import "WebService.h"
#import "WiThrottleService.h"
#import "JMRIItem.h"

@interface JMRIItem (Internal)

#pragma mark Properties

- (void)setState:(NSUInteger)state updateService:(Boolean)update;
- (void)setValue:(NSString *)value updateService:(Boolean)update;

#pragma mark - Communications

- (void)queryFromJsonService:(JsonService *)service;
- (void)queryFromWebService:(WebService *)service;
- (void)queryFromWiThrottleService:(WiThrottleService *)service;
- (void)writeToJsonService:(JsonService *)service;
- (void)writeToWebService:(WebService *)service;
- (void)writeToWiThrottleService:(WiThrottleService *)service;

#pragma mark - Utilities

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIItem *)item;

@end
