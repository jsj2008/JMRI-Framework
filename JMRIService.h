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

@class JMRIService;
@class JMRIItem;

#pragma mark - Delegatation Protocol

@protocol JMRIServiceDelegate

@required
- (void)JMRIService:(JMRIService *)service didNotResolve:(NSDictionary *)errorDict;
- (void)JMRIService:(JMRIService *)service didFailWithError:(NSError *)error;

@optional
- (void)JMRIServiceDidResolveAddress:(JMRIService *)service;
- (void)JMRIServiceWillResolve:(JMRIService *)service;
- (void)JMRIServiceDidOpenConnection:(JMRIService *)service;
- (void)JMRIService:(JMRIService *)service didGetInput:(NSString *)input;

@end

#pragma mark - Interface

@interface JMRIService : NSObject <SimpleServiceDelegate, XMLIOServiceDelegate> {
    
    SimpleService *simple;
    XMLIOService *xmlio;
    WiThrottleService *wiThrottle;
    NSString *domain;
    NSString *hostName;
    NSString *name;
    
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService;

#pragma mark - Properties

@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;
@property (weak) id<NSObject, JMRIServiceDelegate> delegate;

#pragma mark - Service properties

@property (readwrite, strong) SimpleService *simpleService;
@property (readwrite, strong) WiThrottleService *wiThrottleService;
@property (readwrite, strong) XMLIOService *webService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasWebService;
@property Boolean requiresSimpleService;
@property Boolean requiresWiThrottleService;
@property Boolean requiresXmlIOService;
@property Boolean useSimpleService;
@property Boolean useWiThrottleService;
@property Boolean useXmlIOService;

#pragma mark - JMRI element properties

@property (readonly) NSDictionary *lights;
@property (readonly) NSDictionary *memoryVariables;
@property (readonly) NSDictionary *panels;
@property (readonly) JMRIPower *power;
@property (readonly) NSDictionary *reporters;
@property (readonly) NSDictionary *roster;
@property (readonly) NSDictionary *routes;
@property (readonly) NSDictionary *sensors;
@property (readonly) NSDictionary *turnouts;

#pragma mark - JMRI element handling

- (void)monitor:(JMRIItem *)item;
- (void)stopMonitoring:(JMRIItem *)item;
- (Boolean)isMonitoring:(JMRIItem *)item;

@end