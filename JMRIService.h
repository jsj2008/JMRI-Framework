//
//  JMRIService.h
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"

// Known service types
extern NSString *const JMRIServiceSimple;
extern NSString *const JMRIServiceWiThrottle;
extern NSString *const JMRIServiceWeb;

// JMRI XMLIO item types
extern NSString *const JMRITypeFrame;
extern NSString *const JMRITypeMemory;
extern NSString *const JMRITypeMetadata;
extern NSString *const JMRITypePanel;
extern NSString *const JMRITypePower;
extern NSString *const JMRITypeRoster;
extern NSString *const JMRITypeRoute;
extern NSString *const JMRITypeSensor;
extern NSString *const JMRITypeTurnout;

extern NSString *const JMRITXTRecordKeyJMRI;

typedef enum {
	JMRIItemStateUnknown = 0,
	JMRIItemStateActive = 2,
	JMRIItemStateInactive = 4,
	JMRIItemStateInconsistent = 8
} JMRIItemStates;

@interface JMRIService : NSObject {
    
    SimpleService *simple;
    XMLIOService *xmlio;
    WiThrottleService *wiThrottle;
    NSString *domain;
    NSString *hostName;
    NSString *name;
    
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService;

#pragma mark - Properties

@property (readwrite, strong) SimpleService *simpleService;
@property (readwrite, strong) WiThrottleService *wiThrottleService;
@property (readwrite, strong) XMLIOService *webService;
@property (readonly) Boolean hasSimpleService;
@property (readonly) Boolean hasWiThrottleService;
@property (readonly) Boolean hasWebService;
@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;

@end