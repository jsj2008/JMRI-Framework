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

extern NSString *const JMRIServiceSimple;
extern NSString *const JMRIServiceWiThrottle;
extern NSString *const JMRIServiceXmlIO;

@interface JMRIService : NSObject {
    
    SimpleService *simple;
    WiThrottleService *wiThrottle;
    XMLIOService *xmlio;
    
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

#pragma mark - Properties

@property (retain, readwrite) SimpleService *simpleService;
@property (retain, readwrite) WiThrottleService *wiThrottleService;
@property (retain, readwrite) XMLIOService *xmlIOService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasXmlIOService;
@property (retain, readonly) NSArray *addresses;
@property (retain, readonly) NSString *domain;
@property (retain, readonly) NSString *hostName;
@property (retain, readonly) NSString *name;

@end