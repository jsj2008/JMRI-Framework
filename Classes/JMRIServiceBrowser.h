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
@class SimpleServiceBrowser;
@class WiThrottleServiceBrowser;
@class XMLIOServiceBrowser;

@interface JMRIServiceBrowser : NSObject {
    
	BOOL searching;
    JsonServiceBrowser *jsonBrowser;
    SimpleServiceBrowser *simpleBrowser;
    WiThrottleServiceBrowser *wiThrottleBrowser;
    XMLIOServiceBrowser *webBrowser;
    
}

#pragma mark - Initializers

- (id)initForServices:(NSSet *)services;

#pragma mark - Service browser methods

- (void)searchForServices;
- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (void)addServiceWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (void)removeServiceWithName:(NSString *)name;
- (void)stop;

#pragma mark - Utility methods

- (BOOL)containsService:(JMRIService *)service;
- (void)sortServices;
- (NSUInteger)indexOfServiceWithName:(NSString *)name;
- (JMRIService *)serviceWithName:(NSString *)name;

#pragma mark - Properties

@property (weak, nonatomic) id delegate;
@property (readonly) BOOL searching;
@property (nonatomic) NSMutableArray *services;

@end

#pragma mark - JMRI service browser delegate protocol

@protocol JMRIServiceBrowserDelegate

@required
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict;

@optional
- (void)JMRIServiceDidResolveAddress:(JMRIService *)aJMRIService;
- (void)JMRIServiceBrowserWillSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowserDidStopSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didFindService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didRemoveService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didChangeService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;

@end