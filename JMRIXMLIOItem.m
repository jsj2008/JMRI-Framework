//
//  JMRIXMLIOItem.m
//  JMRI Framework
//
//  Created by Randall Wood on 26/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIXMLIOItem.h"
#import "JMRIXMLIOService.h"

@implementation JMRIXMLIOItem

@synthesize name;
@synthesize type;
@synthesize userName;
@synthesize value;
@synthesize comment;
@synthesize inverted;

@synthesize dccAddress;
@synthesize addressLength;
@synthesize roadName;
@synthesize roadNumber;
@synthesize mfg;
@synthesize model;
@synthesize maxSpeedPct;
@synthesize imageFileName;
@synthesize imageIconName;
@synthesize functionLabels;
@synthesize functionLockables;

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIXMLIOItem *)item {
	if (self.userName && item.userName) {
		return [self.userName localizedCaseInsensitiveCompare:item.userName];
	} else if (self.userName && item.name) {
		return [self.userName localizedCaseInsensitiveCompare:item.name];
 	} else if (self.name && item.userName) {
		return [self.name localizedCaseInsensitiveCompare:item.userName];
	}
	return [self.name localizedCaseInsensitiveCompare:item.name];
}

- (id)init {
	if ((self = [super init])) {
		self.name = nil;
		self.type = nil;
		self.userName = nil;
		self.value = nil;
		self.comment = nil;
		self.inverted = nil;
		self.dccAddress = nil;
		self.addressLength = nil;
		self.roadName = nil;
		self.roadNumber = nil;
		self.mfg = nil;
		self.model = nil;
		self.maxSpeedPct = nil;
		self.imageFileName = nil;
		self.imageIconName = nil;
		self.functionLabels = nil;
		self.functionLockables = nil;
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.type = nil;
	self.userName = nil;
	self.value = nil;
	self.comment = nil;
	self.inverted = nil;
	self.dccAddress = nil;
	self.addressLength = nil;
	self.roadName = nil;
	self.roadNumber = nil;
	self.mfg = nil;
	self.model = nil;
	self.maxSpeedPct = nil;
	self.imageFileName = nil;
	self.imageIconName = nil;
	self.functionLabels = nil;
	self.functionLockables = nil;
	[super dealloc];
}

@end
