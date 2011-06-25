/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIXMLIOService.h
//  NScaleApp
//
//  Created by Randall Wood on 4/5/2011.
//

#import "JMRINetService.h"
#import "JMRIXMLIOItem.h"

// JMRI XMLIO item types
extern NSString *const JMRIXMLIOTypeMemory;
extern NSString *const JMRIXMLIOTypeMetadata;
extern NSString *const JMRIXMLIOTypePanel;
extern NSString *const JMRIXMLIOTypePower;
extern NSString *const JMRIXMLIOTypeRoster;
extern NSString *const JMRIXMLIOTypeRoute;
extern NSString *const JMRIXMLIOTypeSensor;
extern NSString *const JMRIXMLIOTypeTurnout;

// JMRI XMLIO item attributes
extern NSString *const JMRIXMLIOItemComment;
extern NSString *const JMRIXMLIOItemInverted;
extern NSString *const JMRIXMLIOItemName;
extern NSString *const JMRIXMLIOItemType;
extern NSString *const JMRIXMLIOItemUserName;
extern NSString *const JMRIXMLIOItemValue;

// JMRI XMLIO roster attributes
extern NSString *const JMRIXMLIORosterDCCAddress;
extern NSString *const JMRIXMLIORosterAddressLength;
extern NSString *const JMRIXMLIORosterRoadName;
extern NSString *const JMRIXMLIORosterRoadNumber;
extern NSString *const JMRIXMLIORosterMFG;
extern NSString *const JMRIXMLIORosterModel;
extern NSString *const JMRIXMLIORosterMaxSpeedPct;
extern NSString *const JMRIXMLIORosterImageFileName;
extern NSString *const JMRIXMLIORosterImageIconName;
extern NSString *const JMRIXMLIORosterFunctions;

// JMRI XMLIO throttle attributes
extern NSString *const JMRIXMLIOThrottleAddress;
extern NSString *const JMRIXMLIOThrottleForward;
extern NSString *const JMRIXMLIOThrottleSpeed;
extern NSString *const JMRIXMLIOThrottleF0;
extern NSString *const JMRIXMLIOThrottleF1;
extern NSString *const JMRIXMLIOThrottleF2;
extern NSString *const JMRIXMLIOThrottleF3;
extern NSString *const JMRIXMLIOThrottleF4;
extern NSString *const JMRIXMLIOThrottleF5;
extern NSString *const JMRIXMLIOThrottleF6;
extern NSString *const JMRIXMLIOThrottleF7;
extern NSString *const JMRIXMLIOThrottleF8;
extern NSString *const JMRIXMLIOThrottleF9;
extern NSString *const JMRIXMLIOThrottleF10;
extern NSString *const JMRIXMLIOThrottleF11;
extern NSString *const JMRIXMLIOThrottleF12;

// JMRI XMLIO common names
extern NSString *const JMRIXMLIOMemoryCurrentTime;
extern NSString *const JMRIXMLIOMemoryRateFactor;
extern NSString *const JMRIXMLIOMetadataJMRIVersion;
extern NSString *const JMRIXMLIOMetadataJVMVendor;
extern NSString *const JMRIXMLIOMetadataJVMVersion;
extern NSString *const JMRIXMLIOSensorClockRunning;

// NSNotification userInfo keys
extern NSString *const JMRIXMLIOServiceDidListItems;
extern NSString *const JMRIXMLIOServiceDidReadItem;
extern NSString *const JMRIXMLIOServiceDidWriteItem;
extern NSString *const JMRIXMLIOItemsListKey;
extern NSString *const JMRIXMLIOItemKey;
extern NSString *const JMRIXMLIOItemNameKey;
extern NSString *const JMRIXMLIOItemTypeKey;
extern NSString *const JMRIXMLIOItemValueKey;

typedef enum {
	JMRIXMLIOOperationNone = 0,
	JMRIXMLIOOperationList,
	JMRIXMLIOOperationRead,
	JMRIXMLIOOperationWrite,
	JMRIXMLIOOperationTest
} JMRIXMLIOOperationType;

typedef enum {
	JMRIXMLIOItemStateUnknown = 0,
	JMRIXMLIOItemStateActive = 2,
	JMRIXMLIOItemStateInactive = 4,
	JMRIXMLIOItemStateInconsistent = 8
} JMRIXMLIOItemStates;

typedef enum {
	JMRIXMLIOPowerStateUnknown = 0,
	JMRIXMLIOPowerStateOn = 2,
	JMRIXMLIOPowerStateOff = 4
} JMRIXMLIOPowerStates;

@protocol JMRIXMLIOServiceDelegate;
@protocol JMRIXMLIOServiceHelperDelegate;

@interface JMRIXMLIOService : JMRINetService {

	NSUInteger connections;
	NSMutableSet *monitoredItems;

}

#pragma mark -
#pragma mark XMLIO methods

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;

- (void)startMonitoring:(NSString *)name ofType:(NSString *)type;
- (void)stopMonitoring:(NSString *)name ofType:(NSString *)type;
- (void)stopMonitoringAllItems;

#pragma mark -
#pragma mark Properties

@property (readonly, retain) NSURL* url;
@property (readonly) BOOL openConnection;
@property (nonatomic, retain) NSString* XMLIOPath;

@end

#pragma mark -
#pragma mark Delegate protocol

@protocol JMRIXMLIOServiceDelegate <JMRINetServiceDelegate>

#pragma mark Required Methods

@required
- (void)JMRIXMLIOService:(JMRIXMLIOService *)service didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)JMRIXMLIOService:(JMRIXMLIOService *)service didListItems:(NSArray *)items ofType:(NSString *)type;
- (void)JMRIXMLIOService:(JMRIXMLIOService *)service didReadItem:(JMRIXMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOService:(JMRIXMLIOService *)service didWriteItem:(JMRIXMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOService:(JMRIXMLIOService *)service didConnectWithRequest:(NSURLRequest *)request;
- (void)JMRIXMLIOServiceDidFinishLoading:(JMRIXMLIOService *)service;

@end