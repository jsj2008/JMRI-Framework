//
//  JMRIService.h
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"

@interface JMRIService : NSObject

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

#pragma mark - Properties

@property (readwrite, strong) SimpleService *simpleService;
@property (readwrite, strong) WiThrottleService *wiThrottleService;
@property (readwrite, strong) XMLIOService *webService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasWebService;
@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;

@end