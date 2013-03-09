/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOService.h
//  NScaleApp
//
//  Created by Randall Wood on 4/5/2011.
//

#import "JMRINetService.h"
#import "XMLIOItem.h"
#import "XMLIOServiceHelper.h"

@class JMRIPower;
@class JMRITurnout;

// JMRI XMLIO throttle type
extern NSString *const JMRITypeThrottle;

// JMRI XMLIO item attributes
extern NSString *const XMLIOItemComment;
extern NSString *const XMLIOItemInverted;
extern NSString *const XMLIOItemName;
extern NSString *const XMLIOItemType;
extern NSString *const XMLIOItemUserName;
extern NSString *const XMLIOItemValue;
extern NSString *const XMLIOItemIsNull;

// JMRI XMLIO roster attributes
extern NSString *const XMLIORosterDCCAddress;
extern NSString *const XMLIORosterAddressLength;
extern NSString *const XMLIORosterRoadName;
extern NSString *const XMLIORosterRoadNumber;
extern NSString *const XMLIORosterMFG;
extern NSString *const XMLIORosterModel;
extern NSString *const XMLIORosterMaxSpeedPct;
extern NSString *const XMLIORosterImageFileName;
extern NSString *const XMLIORosterImageIconName;
extern NSString *const XMLIORosterFunctions;
extern NSUInteger const XMLIORosterMaxFunctions;    // Maximum number of Functions handled by XMLIO

// JMRI XMLIO throttle attributes
extern NSString *const XMLIOThrottleAddress;
extern NSString *const XMLIOThrottleForward;
extern NSString *const XMLIOThrottleSpeed;
extern NSString *const XMLIOThrottleSpeedStepMode;
extern NSString *const XMLIOThrottleF0;
extern NSString *const XMLIOThrottleF1;
extern NSString *const XMLIOThrottleF2;
extern NSString *const XMLIOThrottleF3;
extern NSString *const XMLIOThrottleF4;
extern NSString *const XMLIOThrottleF5;
extern NSString *const XMLIOThrottleF6;
extern NSString *const XMLIOThrottleF7;
extern NSString *const XMLIOThrottleF8;
extern NSString *const XMLIOThrottleF9;
extern NSString *const XMLIOThrottleF10;
extern NSString *const XMLIOThrottleF11;
extern NSString *const XMLIOThrottleF12;
extern NSString *const XMLIOThrottleF13;
extern NSString *const XMLIOThrottleF14;
extern NSString *const XMLIOThrottleF15;
extern NSString *const XMLIOThrottleF16;
extern NSString *const XMLIOThrottleF17;
extern NSString *const XMLIOThrottleF18;
extern NSString *const XMLIOThrottleF19;
extern NSString *const XMLIOThrottleF20;
extern NSString *const XMLIOThrottleF21;
extern NSString *const XMLIOThrottleF22;
extern NSString *const XMLIOThrottleF23;
extern NSString *const XMLIOThrottleF24;
extern NSString *const XMLIOThrottleF25;
extern NSString *const XMLIOThrottleF26;
extern NSString *const XMLIOThrottleF27;
extern NSString *const XMLIOThrottleF28;

// JMRI XMLIO common names
extern NSString *const XMLIOMemoryCurrentTime;
extern NSString *const XMLIOMemoryRateFactor;
extern NSString *const XMLIOMetadataJMRIVersion;
extern NSString *const XMLIOMetadataJMRICanonicalVersion;
extern NSString *const XMLIOMetadataJMRIMajorVersion;
extern NSString *const XMLIOMetadataJMRIMinorVersion;
extern NSString *const XMLIOMetadataJMRITestVersion;
extern NSString *const XMLIOMetadataJVMVendor;
extern NSString *const XMLIOMetadataJVMVersion;
extern NSString *const XMLIOMetadataVersionMajor;
extern NSString *const XMLIOMetadataVersionMinor;
extern NSString *const XMLIOMetadataVersionTest;
extern NSString *const XMLIOSensorClockRunning;

// NSNotification userInfo keys
extern NSString *const XMLIOServiceDidListItems;
extern NSString *const XMLIOServiceDidReadItem;
extern NSString *const XMLIOServiceDidWriteItem;
extern NSString *const XMLIOServiceDidGetThrottle;
extern NSString *const XMLIOItemsListKey;
extern NSString *const XMLIOItemKey;
extern NSString *const XMLIOItemNameKey;
extern NSString *const XMLIOItemTypeKey;
extern NSString *const XMLIOItemValueKey;
extern NSString *const XMLIOThrottleKey;

// NSError keys
extern NSString *const XMLIOErrorDomain;

// JavaISMs
extern NSString *const XMLIOBooleanYES;
extern NSString *const XMLIOBooleanNO;

typedef enum {
	XMLIOOperationNone = 0,
	XMLIOOperationList,
	XMLIOOperationRead,
	XMLIOOperationWrite,
    XMLIOOperationThrottle,
	XMLIOOperationTest
} XMLIOOperationType;

typedef enum {
    XMLIOSpeedStepMode128 = 1,
    XMLIOSpeedStepMode28 = 2,
    XMLIOSpeedStepMode27 = 4,
    XMLIOSpeedStepMode14 = 8
} XMLIOThrottleSpeedSteps;

@protocol XMLIOServiceDelegate;
@protocol XMLIOServiceHelperDelegate;

@class XMLIOThrottle;

@interface XMLIOService : JMRINetService <XMLIOServiceHelperDelegate> {

	NSMutableDictionary *connections;
	NSMutableSet *monitoredItems;
    NSString *XMLIOPath;
    NSMutableDictionary *throttles;

}

#pragma mark - XMLIO methods

- (void)sendThrottle:(NSUInteger)address commands:(NSDictionary *)commands;
- (void)stopThrottle:(NSUInteger)address;
- (void)stopAllThrottles;

- (void)startMonitoring:(NSString *)name ofType:(NSString *)type;
- (void)stopMonitoring:(NSString *)name ofType:(NSString *)type;
- (void)stopMonitoringAllItems;
- (Boolean)isMonitoring:(NSString *)name ofType:(NSString *)type;

- (void)cancelAllConnections;

#pragma mark - XmlIO messages

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;

#pragma mark - JMRI XMLIO Service rethreading

- (void)helperDidFail:(NSDictionary *)parameters;
- (void)helperDidListItems:(NSDictionary *)parameters;
- (void)helperDidReadItem:(NSDictionary *)parameters;
- (void)helperDidWriteItem:(NSDictionary *)parameters;
- (void)helperDidGetThrottle:(NSDictionary *)parameters;
- (void)helperDidConnectWithRequest:(NSDictionary *)parameters;

#pragma mark - Properties

@property (readonly) NSURL* url;
@property (readonly) BOOL openConnection;
@property (nonatomic) NSString* XMLIOPath;
@property (nonatomic) NSMutableDictionary* throttles;

@end

#pragma mark - Delegate protocol

@protocol XMLIOServiceDelegate <JMRINetServiceDelegate>

#pragma mark Optional Methods

@optional
- (void)XMLIOService:(XMLIOService *)service didListItems:(NSArray *)items ofType:(NSString *)type;
- (void)XMLIOService:(XMLIOService *)service didReadItem:(XMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)XMLIOService:(XMLIOService *)service didWriteItem:(XMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)XMLIOService:(XMLIOService *)service didGetThrottle:(XMLIOThrottle *)throttle withAddress:(NSUInteger)address;
- (void)XMLIOService:(XMLIOService *)service didConnectWithRequest:(NSURLRequest *)request;
- (void)XMLIOServiceDidFinishLoading:(XMLIOService *)service;

@end