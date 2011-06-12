//
//  JMRIXMLIOService.h
//  NScaleApp
//
//  Created by Randall Wood on 4/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
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
extern NSString *const JMRIXMLIOItemName;
extern NSString *const JMRIXMLIOItemType;
extern NSString *const JMRIXMLIOItemUserName;
extern NSString *const JMRIXMLIOItemValue;

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