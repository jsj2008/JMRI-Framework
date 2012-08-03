//
//  JMRIConstants.h
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//


// Known service types
extern NSString *const JMRIServiceSimple;
extern NSString *const JMRIServiceWiThrottle;
extern NSString *const JMRIServiceWeb;

// JMRI XMLIO item types
extern NSString *const JMRITypeFrame;
extern NSString *const JMRITypeLight;
extern NSString *const JMRITypeMemory;
extern NSString *const JMRITypeMetadata;
extern NSString *const JMRITypePanel;
extern NSString *const JMRITypePower;
extern NSString *const JMRITypeReporter;
extern NSString *const JMRITypeRoster;
extern NSString *const JMRITypeRoute;
extern NSString *const JMRITypeSensor;
extern NSString *const JMRITypeTurnout;

extern NSString *const JMRITXTRecordKeyJMRI;

typedef enum {
	JMRIItemStateUnknown = 0,
	JMRIItemStateActive = 2,
	JMRIItemStateInactive = 4,
	JMRIItemStateInconsistent = 8,
    JMRIItemStateStateless = INT_MAX
} JMRIItemStates;
