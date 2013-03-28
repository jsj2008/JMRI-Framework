//
//  JMRIConstants.h
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//


// Known service types
extern NSString *const JMRIServiceJson;
extern NSString *const JMRIServiceSimple;
extern NSString *const JMRIServiceWeb;
extern NSString *const JMRIServiceWiThrottle;
extern NSString *const JMRIServiceXmlIO;

// JMRI XMLIO item types
extern NSString *const JMRITypeFrame;
extern NSString *const JMRITypeLight;
extern NSString *const JMRITypeList;
extern NSString *const JMRITypeMemory;
extern NSString *const JMRITypeMetadata;
extern NSString *const JMRITypePanel;
extern NSString *const JMRITypePower;
extern NSString *const JMRITypeReporter;
extern NSString *const JMRITypeRoster;
extern NSString *const JMRITypeRoute;
extern NSString *const JMRITypeSensor;
extern NSString *const JMRITypeSignalHead;
extern NSString *const JMRITypeTurnout;

// JMRI XMLIO common names
extern NSString *const JMRIMemoryCurrentTime;
extern NSString *const JMRIMemoryRateFactor;
extern NSString *const JMRIMetadataJMRIVersion;
extern NSString *const JMRIMetadataJMRICanonicalVersion;
extern NSString *const JMRIMetadataJMRIMajorVersion;
extern NSString *const JMRIMetadataJMRIMinorVersion;
extern NSString *const JMRIMetadataJMRITestVersion;
extern NSString *const JMRIMetadataJVMVendor;
extern NSString *const JMRIMetadataJVMVersion;
extern NSString *const JMRIMetadataVersionMajor;
extern NSString *const JMRIMetadataVersionMinor;
extern NSString *const JMRIMetadataVersionTest;
extern NSString *const JMRISensorClockRunning;

// JMRI Panel elements
extern NSString *const JMRIPanelPositionableLabel;
extern NSString *const JMRIPanelSensorIcon;
extern NSString *const JMRIPanelSignalHeadIcon;
extern NSString *const JMRIPanelTurnoutIcon;

extern NSString *const JMRITXTRecordKeyJMRI;
extern NSString *const JMRIErrorDomain;

typedef enum {
	JMRIItemStateUnknown = 0,
	JMRIItemStateActive = 2,
	JMRIItemStateClosed = 2,
	JMRIItemStateInactive = 4,
	JMRIItemStateThrown = 4,
	JMRIItemStateInconsistent = 8,
    JMRIItemStateStateless = INT_MAX
} JMRIItemStates;

typedef enum {
    JMRISignalAppearanceDark = 0,
    JMRISignalAppearanceRed = 1,
    JMRISignalAppearanceFlashRed = 2,
    JMRISignalAppearanceYellow = 4,
    JMRISignalAppearanceFlashYellow = 8,
    JMRISignalAppearanceGreen = 10,
    JMRISignalAppearanceFlashGreen = 20,
    JMRISignalAppearanceLunar = 40,
    JMRISignalAppearanceFlashLunar = 80
} JMRISignalAppearances;

typedef enum {
    JMRIWebServiceJsonReadOnly = 510,
    JMRIWebServiceJsonUnsupported = 511,
    JMRIXMLUnexpectedRootElement = 512
} JMRIErrorCodes;