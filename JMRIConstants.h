//
//  JMRIConstants.h
//  JMRI-Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//


#pragma mark Known service types
extern NSString *const JMRIServiceJson;
extern NSString *const JMRIServiceWeb;
extern NSString *const JMRIServiceWiThrottle;

#pragma mark JMRI item types
extern NSString *const JMRITypeError;
extern NSString *const JMRITypeFrame;
extern NSString *const JMRITypeHello;
extern NSString *const JMRITypeGoodbye;
extern NSString *const JMRITypeLight;
extern NSString *const JMRITypeList;
extern NSString *const JMRITypeMemory;
extern NSString *const JMRITypeMetadata;
extern NSString *const JMRITypeNetworkServices;
extern NSString *const JMRITypePanel;
extern NSString *const JMRITypePower;
extern NSString *const JMRITypeReporter;
extern NSString *const JMRITypeRoster;
extern NSString *const JMRITypeRosterEntry;
extern NSString *const JMRITypeRoute;
extern NSString *const JMRITypeSensor;
extern NSString *const JMRITypeSignalHead;
extern NSString *const JMRITypeTurnout;

#pragma mark JMRI collections
// where the collection name != contained item type
extern NSString *const JMRIListLights;
extern NSString *const JMRIListMemories;
extern NSString *const JMRIListPanels;
extern NSString *const JMRIListReporters;
extern NSString *const JMRIListRoutes;
extern NSString *const JMRIListSensors;
extern NSString *const JMRIListSignalHeads;
extern NSString *const JMRIListTurnouts;

#pragma mark JMRI known item names
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

#pragma mark JMRI zeroconf elements
extern NSString *const JMRITXTRecordKeyJMRI;
extern NSString *const JMRITXTRecordKeyJSON;

#pragma mark Framework notifications
extern NSString *const JMRINotificationStateChange;
extern NSString *const JMRINotificationItemAdded;
extern NSString *const JMRINotificationBonjourServiceAdded;
extern NSString *const JMRINotificationBonjourServiceRemoved;
extern NSString *const JMRINotificationBrowserDidNotSearch;
extern NSString *const JMRINotificationBrowserDidStopSearch;
extern NSString *const JMRINotificationBrowserWillSearch;
extern NSString *const JMRINotificationDidOpenConnection;
extern NSString *const JMRINotificationDidCloseConnection;
extern NSString *const JMRINotificationDidStart;
extern NSString *const JMRINotificationDidStop;
extern NSString *const JMRINotificationDidFailWithError;

#pragma mark Framework notification userInfo dictionary keys
extern NSString *const JMRIAddedBonjourService;
extern NSString *const JMRIItemKey;
extern NSString *const JMRIChangedService;
extern NSString *const JMRIList;
extern NSString *const JMRIRemovedBonjourService;
extern NSString *const JMRIServiceKey;
extern NSString *const JMRIType;

#pragma mark Signal head appearance names
extern NSString *const JMRISignalAppearanceTextDark;
extern NSString *const JMRISignalAppearanceTextFlashGreen;
extern NSString *const JMRISignalAppearanceTextFlashLunar;
extern NSString *const JMRISignalAppearanceTextFlashRed;
extern NSString *const JMRISignalAppearanceTextFlashYellow;
extern NSString *const JMRISignalAppearanceTextGreen;
extern NSString *const JMRISignalAppearanceTextHeld;
extern NSString *const JMRISignalAppearanceTextLunar;
extern NSString *const JMRISignalAppearanceTextRed;
extern NSString *const JMRISignalAppearanceTextYellow;

#pragma mark Framework error domain
extern NSString *const JMRIErrorDomain;

#pragma mark Item attributes
extern NSString *const JMRIItemComment;
extern NSString *const JMRIItemInverted;
extern NSString *const JMRIItemName;
extern NSString *const JMRIItemState;
extern NSString *const JMRIItemUserName;
extern NSString *const JMRIItemValue;
extern NSString *const JMRIItemReport;
extern NSString *const JMRIItemLastReport;

#pragma mark JSON elements
extern NSString *const JMRIJsonData;

#pragma mark HTTP methods
extern NSString *const HTTPMethodPost;
extern NSString *const HTTPMethodPut;

#pragma mark JMRI states
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

#pragma mark Signal head appearances
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

#pragma mark Framework error codes
typedef enum {
    JMRIMalformedRequest = 400,
    JMRICannotCreateItem = 403,
    JMRIItemNotFound = 404,
    JMRIInternalError = 500,
    JMRIWebServiceJsonUnsupported = 611,
    JMRIXMLUnexpectedRootElement = 612,
    JMRIInputStreamError = 613,
    JMRIOutputStreamError = 614
} JMRIErrorCodes;
