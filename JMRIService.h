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

@interface JMRIService : NSObject {
    
    SimpleService *simple;
    WiThrottleService *wiThrottle;
    XMLIOService *xmlio;
    
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

#pragma mark - Properties

@property (readwrite) SimpleService *simpleService;
@property (readwrite) WiThrottleService *wiThrottleService;
@property (readwrite) XMLIOService *xmlIOService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasXmlIOService;
@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;

@end