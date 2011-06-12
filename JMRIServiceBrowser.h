//
//  JMRIServiceBrowser.h
//  JMRI Framework
//
//  Created by Randall Wood on 7/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIWiThrottleService.h"
#import "JMRIXMLIOService.h"
#import "NSArray+JMRIExtensions.h"

extern NSString *const JMRIServiceTypeWiThrottle;
extern NSString *const JMRIServiceTypeXMLIO;

@interface JMRIServiceBrowser : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {

	NSNetServiceBrowser *_browser;
	id _delegate;
	BOOL _searching;
	NSMutableArray *_services;
}

#pragma mark Service browser methods

- (void)searchForServices;
- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port;
- (void)stop;

#pragma mark -
#pragma mark Utility methods

- (BOOL)containsService:(NSNetService *)service;
- (void)sortServices;
- (NSUInteger)indexOfServiceWithName:(NSString *)name;
- (JMRINetService *)serviceWithName:(NSString *)name;

#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) NSNetServiceBrowser *browser;
@property (nonatomic, retain) id delegate;
@property (readonly) BOOL searching;
@property (nonatomic, retain) NSMutableArray *services;

@end

#pragma mark -
#pragma mark JMRI service browser delegate protocol

@protocol JMRIServiceBrowserDelegate

@required
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict;

@optional
- (void)JMRIServiceBrowserWillSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowserDidStopSearch:(JMRIServiceBrowser *)browser;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didFindService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing;
- (void)JMRIServiceBrowser:(JMRIServiceBrowser *)browser didRemoveService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing;

@end