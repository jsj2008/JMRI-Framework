//
//  JMRIConstants.m
//  JMRI Framework
//
//  Created by Randall Wood on 15/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIConstants.h"

#pragma mark Known service types
NSString *const JMRIServiceJson = @"jsonService";
NSString *const JMRIServiceSimple = @"simpleService";
NSString *const JMRIServiceWeb = @"webService";
NSString *const JMRIServiceWiThrottle = @"wiThrottleService";
NSString *const JMRIServiceXmlIO = @"xmlIOService";

#pragma mark JMRI item types
NSString *const JMRITypeError = @"error";
NSString *const JMRITypeFrame = @"frame";
NSString *const JMRITypeHello = @"hello";
NSString *const JMRITypeGoodbye = @"goodbye";
NSString *const JMRITypeLight = @"light";
NSString *const JMRITypeList = @"list";
NSString *const JMRITypeMemory = @"memory";
NSString *const JMRITypeMetadata = @"metadata";
NSString *const JMRITypeNetworkServices = @"networkServices";
NSString *const JMRITypePanel = @"panel";
NSString *const JMRITypePower = @"power";
NSString *const JMRITypeReporter = @"reporter";
NSString *const JMRITypeRoster = @"roster";
NSString *const JMRITypeRosterEntry = @"rosterEntry";
NSString *const JMRITypeRoute = @"route";
NSString *const JMRITypeSensor = @"sensor";
NSString *const JMRITypeSignalHead = @"signalHead";
NSString *const JMRITypeTurnout = @"turnout";

#pragma mark JMRI collections
// where the collection name != contained item type
NSString *const JMRIListLights = @"lights";
NSString *const JMRIListMemories = @"memories";
NSString *const JMRIListPanels = @"panels";
NSString *const JMRIListReporters = @"reporters";
NSString *const JMRIListRoutes = @"routes";
NSString *const JMRIListSensors = @"sensors";
NSString *const JMRIListSignalHeads = @"signalHeads";
NSString *const JMRIListTurnouts = @"turnouts";

#pragma mark JMRI known item names
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

#pragma mark JMRI zeroconf elements
NSString *const JMRITXTRecordKeyJMRI = @"jmri";
NSString *const JMRITXTRecordKeyJSON = @"json";

#pragma mark Framework notifications
NSString *const JMRINotificationStateChange = @"JMRINotificationStateChange";
NSString *const JMRINotificationItemAdded = @"JMRINotificationItemAdded";
NSString *const JMRINotificationBonjourServiceAdded = @"JMRINotificationBonjourServiceAdded";
NSString *const JMRINotificationBonjourServiceRemoved = @"JMRINotificationBonjourServiceRemoved";
NSString *const JMRINotificationBrowserDidNotSearch = @"JMRINotificationBrowserDidNotSearch";
NSString *const JMRINotificationBrowserDidStopSearch = @"JMRINotificationBrowserDidStopSearch";
NSString *const JMRINotificationBrowserWillSearch = @"JMRINotificationBrowserWillSearch";
NSString *const JMRINotificationDidOpenConnection = @"JMRINotificationDidOpenConnection";
NSString *const JMRINotificationDidCloseConnection = @"JMRINotificationDidCloseConnection";
NSString *const JMRINotificationDidStart = @"JMRINotificationDidStart";
NSString *const JMRINotificationDidStop = @"JMRINotificationDidStop";
NSString *const JMRINotificationDidFailWithError = @"JMRINotificationDidFailWithError";

#pragma mark Framework notification userInfo dictionary keys
NSString *const JMRIAddedBonjourService = @"JMRIAddedBonjourService";
NSString *const JMRIAddedItem = @"item";
NSString *const JMRIChangedService = @"JMRIChangedService";
NSString *const JMRIErrorKey = @"error";
NSString *const JMRIList = @"list";
NSString *const JMRIRemovedBonjourService = @"JMRIRemovedBonjourService";
NSString *const JMRIServiceKey = @"service";
NSString *const JMRIType = @"type";

#pragma mark Signal head appearance names
NSString *const JMRISignalAppearanceTextFlashYellow = @"flashyellow";
NSString *const JMRISignalAppearanceTextGreen = @"green";
NSString *const JMRISignalAppearanceTextRed = @"red";
NSString *const JMRISignalAppearanceTextYellow = @"yellow";
NSString *const JMRISignalAppearanceTextDark = @"dark";
NSString *const JMRISignalAppearanceTextFlashGreen = @"flashgreen";
NSString *const JMRISignalAppearanceTextFlashLunar = @"flashlunar";
NSString *const JMRISignalAppearanceTextFlashRed = @"flashred";
NSString *const JMRISignalAppearanceTextHeld = @"held";
NSString *const JMRISignalAppearanceTextLunar = @"lunar";

#pragma mark Framework error domain
NSString *const JMRIErrorDomain = @"JMRIError";

#pragma mark JSON elements
NSString *const JMRIJsonComment = @"comment";
NSString *const JMRIJsonData = @"data";
NSString *const JMRIJsonInverted = @"inverted";
NSString *const JMRIItemName = @"name";
NSString *const JMRIItemState = @"state";
NSString *const JMRIJsonUserName = @"userName";
NSString *const JMRIItemValue = @"value";
