//
//  JMRIService.h
//  JMRI-Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMRIService;
@class JMRINetService;
@class JsonService;
@class WebService;
@class WiThrottleService;
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
    WebService *web;
    WiThrottleService *wiThrottle;
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
 - *JMRIServiceWeb*
 - *JMRIServiceWiThrottle*
 
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
@property (readwrite, strong) WebService *webService;
@property (readwrite, strong) WiThrottleService *wiThrottleService;
@property (readonly) Boolean hasJsonService;
@property (readonly) Boolean hasWebService;
@property (readonly) Boolean hasWiThrottleService;
@property Boolean requiresJsonService;
@property Boolean requiresWebService;
@property Boolean requiresWiThrottleService;
@property Boolean useJsonService;
@property Boolean useWebService;
@property Boolean useWiThrottleService;

/**
 Log events and network activities.
 
 Default is NO.
 */
@property Boolean logEvents;
/**
 The JMRI server version.
 
 This property may be difficult to determine accurately for JMRI versions earlier than 3.2. 
 */
@property (readonly, strong) NSString *version;

#pragma mark - JMRI element properties
/** @name JMRI Elements */

/**
 JMRI lights.
 */
@property (readonly) NSMutableDictionary *lights;
/**
 JMRI memory objects.
 */
@property (readonly) NSMutableDictionary *memories;
/**
 Information about JMRI itself.
 */
@property (readonly) NSMutableDictionary *metadata;
/**
 JMRI CTC panels.
 */
@property (readonly) NSMutableDictionary *panels;
/**
 JMRI track power.
 
 Note that this dictionary will always have only one element in it.
 */
@property (readonly) NSMutableDictionary *power;
/**
 JMRI reporters.
 */
@property (readonly) NSMutableDictionary *reporters;
/**
 JMRI roster entries.
 */
@property (readonly) NSMutableDictionary *roster;
/**
 JMRI routes.
 */
@property (readonly) NSMutableDictionary *routes;
/**
 JMRI sensors.
 */
@property (readonly) NSMutableDictionary *sensors;
/**
 JMRI signal heads.
 */
@property (readonly) NSMutableDictionary *signalHeads;
/**
 JMRI turnouts.
 */
@property (readonly) NSMutableDictionary *turnouts;

#pragma mark - JMRI element handling

/**
 Request a list of items of a certain type from the JMRI service.

 This method will silently fail if the JMRI server is only publishing Simple and WiThrottle services.
 
 @param type The type of items to list
 */
- (void)list:(NSString *)type;
/**
 Stop all network connections to a JMRI service.
 
 Cleanly closes the JSON, WebSocket and WiThrottle service connections.
 */
- (void)stop;

#pragma mark - Utilities
/** @name Utilities */

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
 
 @param collection The name of the collection
 @return The type of JMRI item in the collection
 */
- (NSString *)typeForCollection:(NSString *)collection;

@end
