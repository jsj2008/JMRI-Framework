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

// JMRI item types
extern NSString *const JMRITypeFrame;
extern NSString *const JMRITypeLight;
extern NSString *const JMRITypeList;
extern NSString *const JMRITypeMemory;
extern NSString *const JMRITypeMetadata;
extern NSString *const JMRITypePanel;
extern NSString *const JMRITypePower;
extern NSString *const JMRITypeReporter;
extern NSString *const JMRITypeRoster;
extern NSString *const JMRITypeRosterEntry;
extern NSString *const JMRITypeRoute;
extern NSString *const JMRITypeSensor;
extern NSString *const JMRITypeSignalHead;
extern NSString *const JMRITypeTurnout;

// JMRI collections (where the collection name != contained item type)
extern NSString *const JMRIListLights;
extern NSString *const JMRIListMemories;
extern NSString *const JMRIListPanels;
extern NSString *const JMRIListReporters;
extern NSString *const JMRIListRoutes;
extern NSString *const JMRIListSensors;
extern NSString *const JMRIListSignalHeads;
extern NSString *const JMRIListTurnouts;

// JMRI known item names
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

// JMRI panel elements
extern NSString *const JMRIPanelPositionableLabel;
extern NSString *const JMRIPanelSensorIcon;
extern NSString *const JMRIPanelSignalHeadIcon;
extern NSString *const JMRIPanelTurnoutIcon;

// JMRI zeroconf elements
extern NSString *const JMRITXTRecordKeyJMRI;

// Framework notifications
extern NSString *const JMRINotificationStateChange;
extern NSString *const JMRINotificationItemAdded;
extern NSString *const JMRINotificationBonjourServiceAdded;
extern NSString *const JMRINotificationBonjourServiceRemoved;
extern NSString *const JMRINotificationBrowserDidNotSearch;
extern NSString *const JMRINotificationBrowserDidStopSearch;
extern NSString *const JMRINotificationBrowserWillSearch;

// Framework notification userInfo dictionary keys
extern NSString *const JMRIAddedItem;
extern NSString *const JMRIChangedService;
extern NSString *const JMRIList;
extern NSString *const JMRIAddedBonjourService;
extern NSString *const JMRIRemovedBonjourService;
extern NSString *const JMRIType;

// Framework error domain
extern NSString *const JMRIErrorDomain;

// JMRI states
// Need to maintain two Unknown states due to inconsistencies in JMRI
typedef enum {
	JMRIItemStateUnknown = 0,
    JMRIBeanStateUnknown = 1,
	JMRIItemStateActive = 2,
	JMRIItemStateClosed = 2,
	JMRIItemStateInactive = 4,
	JMRIItemStateThrown = 4,
	JMRIItemStateInconsistent = 8,
    JMRIItemStateStateless = INT_MAX
} JMRIItemStates;

// Signal head appearances
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

// Framework error codes
typedef enum {
    JMRIMalformedRequest = 400,
    JMRICannotCreateItem = 403,
    JMRIItemNotFound = 404,
    JMRIInternalError = 500,
    JMRIWebServiceJsonReadOnly = 510,
    JMRIWebServiceJsonUnsupported = 511,
    JMRIXMLUnexpectedRootElement = 512
} JMRIErrorCodes;