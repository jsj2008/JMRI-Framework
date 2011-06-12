//
//  JMRINetService.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+JMRIExtensions.h"

@interface JMRINetService : NSObject <NSNetServiceDelegate> {

	NSNetService *_service;
	id delegate;
	BOOL logTraffic;
	NSString *manualAddress;
	NSInteger manualPort;

}

#pragma mark -
#pragma mark Object handling

- (id)initWithNetService:(NSNetService *)service;
- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port;
- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService;

#pragma mark -
#pragma mark Net service handling

- (void)resolveWithTimeout:(NSTimeInterval)timeout;
- (void)startMonitoring;
- (void)stop;
- (void)stopMonitoring;
- (BOOL)testConnection;

#pragma mark -
#pragma mark Object properties

@property (retain) id delegate;
@property (retain) NSNetService *service;
@property BOOL logTraffic;
@property NSTimeInterval timeoutInterval;
@property (readonly) BOOL resolved;

#pragma mark -
#pragma mark Net service properties

@property (retain, readonly) NSArray *addresses;
@property (retain, readonly) NSString *domain;
@property (retain, readonly) NSString *hostname;
@property (retain, readonly) NSString *name;
@property (readonly) NSInteger port;

@end

@protocol JMRINetServiceDelegate

@required
- (void)JMRINetService:(JMRINetService *)service didNotResolve:(NSDictionary *)errorDict;

@optional
- (void)JMRINetServiceDidResolveAddress:(JMRINetService *)service;
- (void)JMRINetServiceWillResolve:(JMRINetService *)service;

@end