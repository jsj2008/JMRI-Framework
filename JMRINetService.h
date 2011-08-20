/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRINetService.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/5/2011.
//

#define MIN_JMRI_VERSION @"2.12"

#import <Foundation/Foundation.h>
#import "NSArray+JMRIExtensions.h"

extern NSString *const JMRITXTRecordKeyJMRI;

@interface JMRINetService : NSObject <NSNetServiceDelegate> {

	NSNetService *_service;
	id delegate;
    NSTimeInterval timeoutInterval;
	BOOL logTraffic;
	NSString *manualAddress;
	NSInteger manualPort;
    NSString *version_;

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

#pragma mark -
#pragma mark Object properties

@property (retain) id delegate;
@property (retain) NSNetService *service;
@property BOOL logTraffic;
@property NSTimeInterval timeoutInterval;
@property (readonly) BOOL resolved;
@property (readonly, retain) NSString *version;

#pragma mark -
#pragma mark Net service properties

@property (retain, readonly) NSArray *addresses;
@property (retain, readonly) NSString *domain;
@property (retain, readonly) NSString *hostName;
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