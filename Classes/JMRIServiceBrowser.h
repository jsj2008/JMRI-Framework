//
//  JMRIServiceBrowser.h
//  JMRI Framework
//
//  Created by Randall Wood on 8/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMRIService.h"
#import "SimpleServiceBrowser.h"
#import "WiThrottleServiceBrowser.h"
#import "XMLIOServiceBrowser.h"

@interface JMRIServiceBrowser : NSObject <JMRINetServiceBrowserDelegate> {
    
	BOOL searching;
    NSMutableArray *services;
    SimpleServiceBrowser *simpleBrowser;
    WiThrottleServiceBrowser *wiThrottleBrowser;
    XMLIOServiceBrowser *xmlIOBrowser;
    
}

#pragma mark - Service browser methods

- (void)searchForServices;
- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (void)stop;

#pragma mark - Utility methods

- (BOOL)containsService:(JMRIService *)service;
- (void)sortServices;
- (NSUInteger)indexOfServiceWithName:(NSString *)name;
- (JMRIService *)serviceWithName:(NSString *)name;

#pragma mark - Properties

@property (weak, nonatomic) id delegate;
@property (readonly) BOOL searching;
@property (nonatomic, retain) NSMutableArray *services;

@end

#pragma mark - JMRI service browser delegate protocol

@protocol JMRIServiceBrowserDelegate

@required
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict;

@optional
- (void)JMRIServiceBrowserWillSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowserDidStopSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didFindService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didRemoveService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didChangeService:(JMRIService *)aJMRIService moreComing:(BOOL)moreComing;

@end