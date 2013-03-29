//
//  JMRIService.h
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMRIService;
@class JMRINetService;
@class JsonService;
@class SimpleService;
@class WebService;
@class WiThrottleService;
@class XMLIOService;
@class JMRIItem;
@class JMRIPower;

#pragma mark - Delegatation Protocol

@protocol JMRIServiceDelegate

@required
- (void)JMRIService:(JMRIService *)service didNotResolve:(NSDictionary *)errorDict;
- (void)JMRIService:(JMRIService *)service didFailWithError:(NSError *)error;

@optional
- (void)JMRIServiceDidResolveAddress:(JMRIService *)service;
- (void)JMRIServiceWillResolve:(JMRIService *)service;
- (void)JMRIServiceDidOpenConnection:(JMRIService *)service;
- (void)JMRIServiceDidCloseConnection:(JMRIService *)service;
- (void)JMRIService:(JMRIService *)service didStart:(JMRINetService *)netService;
- (void)JMRIService:(JMRIService *)service didStop:(JMRINetService *)netService;
- (void)JMRIService:(JMRIService *)service didGetInput:(NSString *)input;
- (void)JMRIService:(JMRIService *)service didAddItem:(JMRIItem *)item toList:(NSDictionary *)list;

@end

#pragma mark - Interface

@interface JMRIService : NSObject {
    
    JsonService *json;
    SimpleService *simple;
    WebService *web;
    WiThrottleService *wiThrottle;
    XMLIOService *xmlio;
    NSString *domain;
    NSString *hostName;
    NSString *_name;
    
    NSDictionary *_collections;
    NSDictionary *_types;
}

#pragma mark - Initialization

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithServices:(NSDictionary *)services;

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService *)aService;

#pragma mark - Properties

@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;
@property (weak) id<NSObject, JMRIServiceDelegate> delegate;

#pragma mark - Service properties

@property (readwrite, strong) JsonService *jsonService;
@property (readwrite, strong) SimpleService *simpleService;
@property (readwrite, strong) WebService *webService;
@property (readwrite, strong) WiThrottleService *wiThrottleService;
@property (readwrite, strong) XMLIOService *xmlIOService;
@property (readonly) Boolean hasJsonService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWebService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasXmlIOService;
@property Boolean requiresJsonService;
@property Boolean requiresSimpleService;
@property Boolean requiresWebService;
@property Boolean requiresWiThrottleService;
@property Boolean requiresXmlIOService;
@property Boolean useJsonService;
@property Boolean useSimpleService;
@property Boolean useWebService;
@property Boolean useWiThrottleService;
@property Boolean useXmlIOService;

@property Boolean logNetworkActivity;
@property (readonly, strong) NSString *version;

#pragma mark - JMRI element properties

@property (readonly) NSMutableDictionary *lights;
@property (readonly) NSMutableDictionary *memories;
@property (readonly) NSMutableDictionary *metadata;
@property (readonly) NSMutableDictionary *panels;
@property (readonly) NSMutableDictionary *power;
@property (readonly) NSMutableDictionary *reporters;
@property (readonly) NSMutableDictionary *roster;
@property (readonly) NSMutableDictionary *routes;
@property (readonly) NSMutableDictionary *sensors;
@property (readonly) NSMutableDictionary *signalHeads;
@property (readonly) NSMutableDictionary *turnouts;

#pragma mark - JMRI element handling

- (void)list:(NSString *)type;
- (void)monitor:(JMRIItem *)item;
- (void)stopMonitoring:(JMRIItem *)item;
- (void)stopMonitoringAllItems;
- (Boolean)isMonitoring:(JMRIItem *)item;

- (void)stop;

#pragma mark - Utilities

- (NSString *)collectionForType:(NSString *)type;
- (NSString *)typeForCollection:(NSString *)collection;

@end