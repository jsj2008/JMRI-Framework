//
//  JMRIServiceBrowser.h
//  JMRI Framework
//
//  Created by Randall Wood on 8/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMRIService;
@class JsonServiceBrowser;
@class WiThrottleServiceBrowser;
@class WebServiceBrowser;

/**
 Find published JMRI servers on a network using zeroconf networking.
 */
@interface JMRIServiceBrowser : NSObject {
    
	BOOL searching;
    JsonServiceBrowser *jsonBrowser;
    WiThrottleServiceBrowser *wiThrottleBrowser;
    WebServiceBrowser *webBrowser;
    
}

#pragma mark - Initialization & disposal
/** @name Initialization & disposal */

/**
 Create a browser, allowing it to enumerate all JMRI servers, irregardless of the services enabled on the server.
 */
- (id)init;

/**
 Create a browser, requiring that it only enumerate JMRI servers providing specified services.
 
 Valid services are JMRIServiceJson, JMRIServiceWeb, and JMRIServiceWiThrottle.
 
 @param services A set of service types.
 */
- (id)initForServices:(NSSet *)services;

#pragma mark - Services & browsing
/** @name Services & browsing */

/**
 Start searching for services.
 */
- (void)searchForServices;
/**
 Manually add an unnamed service.
 
 This method calls addServiceWithName:withAddress:withPorts: using the address as the name.
 
 @param address A hostname or IP address for the JMRI server.
 @param ports A dictionary containing key/value pairs where a service is the key and the value is an NSNumber for the port.
 @sa addServiceWithName:withAddress:withPorts:
 */
- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
/**
 Manually add a service.
 
 This method allows JMRI servers that are not discoverable using zeroconf networking to be added to the list of services
 available to the browser, allowing implementing applications to rely solely on the browser for service listings.
 
 @param name The name of the JMRI server. This name can be a model railroad name instead of a hostname, for example.
 @param address A hostname or IP address for the JMRI server.
 @param ports A dictionary containing key/value pairs where a service is the key and the value is an NSNumber for the port.
 */
- (void)addServiceWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports;
/**
 Remove the service with the given name from the browser's list of services.
 
 @param name The name of the JMRI server to remove.
 */
- (void)removeServiceWithName:(NSString *)name;
/**
 Stop ongoing searches for services.
 
 Use this method to ensure that (for example) an iOS app will not continue to attempt service discovery when a view
 listing JMRI servers is dismissed, or when the application looses focus.
 */
- (void)stop;

#pragma mark - Utilities
/** @name Utilities */

/**
 Test if the services array contains a service.
 
 This test relys on the name of the service to make this determination.
 
 @param service The service to test against.
 */
- (BOOL)containsService:(JMRIService *)service;
/**
 Sorts the services array by name.
 */
- (void)sortServices;
/**
 Get the index of the named service in the services array.
 
 @param name The service name.
 */
- (NSUInteger)indexOfServiceWithName:(NSString *)name;
/**
 Get the service with the specified name.
 
 @param name The service name.
 */
- (JMRIService *)serviceWithName:(NSString *)name;

#pragma mark - Properties
/** @name Properties */

/**
 The delegate.
 */
@property (weak, nonatomic) id delegate;
/**
 Check if a search for new services is ongoing or not. YES if searches are ongoing.
 */
@property (readonly) BOOL searching;
/**
 Known JMRI servers, both discovered, and manually entered.
 */
@property (nonatomic) NSMutableArray *services;
/**
 Services that must be provided by a JMRI server for the browser to retain it while searching.
 */
@property (readonly) NSSet *requiredServices;
/**
 Log all events as they occur. Defaults to NO.
 */
@property BOOL logEvents;
@end

#pragma mark - JMRI service browser delegate protocol

@protocol JMRIServiceBrowserDelegate

@required
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict forType:(NSString *)type;

@optional
- (void)JMRIServiceDidResolveAddress:(JMRIService *)aJMRIService;
- (void)JMRIServiceBrowserWillSearch:(JMRIServiceBrowser *)browser forType:(NSString *)type;
- (void)JMRIServiceBrowserDidStopSearch:(JMRIServiceBrowser *)browser forType:(NSString *)type;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didFindService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didRemoveService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didChangeService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;

@end