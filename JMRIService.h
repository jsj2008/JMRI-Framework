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

#pragma mark - Initialization & disposal
/** @name Initialization & disposal */

/**
 Manually create a JMRI service definition.
 
 If you are using a JMRIServiceBrowser, you should use [JMRIServiceBrowser addServiceWithName:withAddress:withPorts:] instead.
 
 The ports dictionary maps services that can be enabled in JMRI to ports, and can have the following keys:
 - *JMRIServiceJson*
 - *JMRIServiceSimple*
 - *JMRIServiceWeb*
 - *JMRIServiceWiThrottle*
 - *JMRIServiceXmlIO* (ignored if JMRIServiceWeb is used as a key)
 
 @param name The name of the service.
 @param address The domain name or IP address of the service.
 @param ports A dictionary mapping services to ports.
 @sa [JMRIServiceBrowser addServiceWithName:withAddress:withPorts:]
 */
- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports;
/**
 Manually create a JMRI service definition, using the address as the name.
 
 This method calls initWithName:withAddress:withPorts: using the address as the name.

 If you are using a JMRIServiceBrowser, you should use [JMRIServiceBrowser addServiceWithAddress:withPorts:] instead.

 @param address The domain name or IP address of the service.
 @param ports A dictionary mapping services to ports.
 @see initWithName:withAddress:withPorts:
 @sa [JMRIServiceBrowser addServiceWithAddress:withPorts:]
 */
- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;

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

/**
 Request a list of items of a certain type from the JMRI service.

 This method will silently fail if the JMRI server is only publishing Simple and WiThrottle services.
 
 @param type The type of items to list
 */
- (void)list:(NSString *)type;
/**
 Request that the JMRI service provide status updates for an item.
 
 You should rarely need to invoke this method; use [JMRIItem monitor] instead.
 
 Since the JSON, Simple, and WiThrottle services all automatically monitor items, and the Web service
 does not provide a monitoring capability, this method does nothing unless the XmlIO service is in use.
 
 @param item The item to monitor.
 @see [JMRIItem monitor]
 */
- (void)monitor:(JMRIItem *)item;
/**
 Stop requesting that the JMRI service provide status updates for an item.
 
 You should rarely need to invoke this method; use [JMRIItem stopMonitoring] instead.
 
 Since the JSON, Simple, and WiThrottle services all automatically monitor items, and the Web service
 does not provide a monitoring capability, this method does nothing unless the XmlIO service is in use. Note
 that the services that automatically monitor items cannot be stopped from providing updates to an item's
 state without breaking the connection to the service.
 
 @param item The item to stop monitoring.
 @see [JMRIItem stopMonitoring]
 */
- (void)stopMonitoring:(JMRIItem *)item;
/**
 Stop requesting that the JMRI service provide status updates for all items.
 
 Since the JSON, Simple, and WiThrottle services all automatically monitor items, and the Web service
 does not provide a monitoring capability, this method does nothing unless the XmlIO service is in use. Note
 that the services that automatically monitor items cannot be stopped from providing updates to an item's
 state without breaking the connection to the service.
 */
- (void)stopMonitoringAllItems;
/**
 Is the JMRI service monitoring an item?
 
 Returns YES if the XmlIO service is monitoring an item, and NO in all other cases.
 
 Since the JSON, Simple, and WiThrottle services all automatically monitor items, and the Web service
 does not provide a monitoring capability, this method returns NO unless the XmlIO service is monitoring the item.
 Note that the services that automatically monitor items cannot be stopped from providing updates to an item's
 state without breaking the connection to the service.
 
 @param item The item to stop monitoring.
 */
- (Boolean)isMonitoring:(JMRIItem *)item;
/**
 Stop all network connections to a JMRI service.
 
 Cleanly closes the JSON, Simple, and WiThrottle service connections and stops any XmlIO monitoring.
 */
- (void)stop;

#pragma mark - Utilities

/**
 Return the collection name that represents a JMRI item type.

 Some JMRI items are listed in collections, the name of which is not formed by simply tacking an _S_ onto
 the end of the type. This method uses a dictionary to get the collection token for a given type.
 
 @param type The token for the type
 @return The collection for the type
 */
- (NSString *)collectionForType:(NSString *)type;
/**
 Return the type name for a given collection.
 
 Some JMRI items are listed in collections, the name of which is not formed by simply tacking an _S_ onto
 the end of the type. This method uses a dictionary to get type string for a given collection name.
 
 @param type The name of the collection
 @return The type of JMRI item in the collection
 */
- (NSString *)typeForCollection:(NSString *)collection;

@end