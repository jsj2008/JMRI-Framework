//
//  JMRIConstants.m
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIConstants.h"

// Known service types
NSString *const JMRIServiceJson = @"JsonService";
NSString *const JMRIServiceSimple = @"JMRINetwork";
NSString *const JMRIServiceWeb = @"WebService (Json)";
NSString *const JMRIServiceWiThrottle = @"wiThrottle";
NSString *const JMRIServiceXmlIO = @"WebService (XmlIO)";

// JMRI item types
NSString *const JMRITypeFrame = @"frame";
NSString *const JMRITypeLight = @"light";
NSString *const JMRITypeList = @"list";
NSString *const JMRITypeMemory = @"memory";
NSString *const JMRITypeMetadata = @"metadata";
NSString *const JMRITypePanel = @"panel";
NSString *const JMRITypePower = @"power";
NSString *const JMRITypeReporter = @"reporter";
NSString *const JMRITypeRoster = @"roster";
NSString *const JMRITypeRosterEntry = @"rosterEntry";
NSString *const JMRITypeRoute = @"route";
NSString *const JMRITypeSensor = @"sensor";
NSString *const JMRITypeSignalHead = @"signalHead";
NSString *const JMRITypeTurnout = @"turnout";

// JMRI collections (where the collection name != contained item type)
NSString *const JMRIListLights = @"lights";
NSString *const JMRIListMemories = @"memories";
NSString *const JMRIListPanels = @"panels";
NSString *const JMRIListReporters = @"reporters";
NSString *const JMRIListRoutes = @"routes";
NSString *const JMRIListSensors = @"sensors";
NSString *const JMRIListSignalHeads = @"signalHeads";
NSString *const JMRIListTurnouts = @"turnouts";

// JMRI known item names
NSString *const JMRIMemoryCurrentTime = @"IMCURRENTTIME";
NSString *const JMRIMemoryRateFactor = @"IMRATEFACTOR";
NSString *const JMRIMetadataJMRIVersion = @"JMRIVERSION";
NSString *const JMRIMetadataJMRICanonicalVersion = @"JMRIVERCANON";
NSString *const JMRIMetadataJMRIMajorVersion = @"JMRIVERMAJOR";
NSString *const JMRIMetadataJMRIMinorVersion = @"JMRIVERMINOR";
NSString *const JMRIMetadataJMRITestVersion = @"JMRIVERTEST";
NSString *const JMRIMetadataJVMVendor = @"JVMVENDOR";
NSString *const JMRIMetadataJVMVersion = @"JVMVERSION";
NSString *const JMRIMetadataVersionMajor = @"major";
NSString *const JMRIMetadataVersionMinor = @"minor";
NSString *const JMRIMetadataVersionTest = @"test";
NSString *const JMRISensorClockRunning = @"ISCLOCKRUNNING";

// JMRI panel elements
NSString *const JMRIPanelPositionableLabel = @"positionablelabel";
NSString *const JMRIPanelSensorIcon = @"sensoricon";
NSString *const JMRIPanelSignalHeadIcon = @"signalheadicon";
NSString *const JMRIPanelTurnoutIcon = @"turnouticon";

// JMRI zeroconf elements
NSString *const JMRITXTRecordKeyJMRI = @"jmri";

// Framework notifications
NSString *const JMRINotificationStateChange = @"JMRINotificationStateChange";
NSString *const JMRINotificationItemAdded = @"JMRINotificationItemAdded";

// Framework notification userInfo dictionary keys
NSString *const JMRIAddedItem = @"item";
NSString *const JMRIList = @"list";

// Framework error domain
NSString *const JMRIErrorDomain = @"JMRIError";

