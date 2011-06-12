//
//  JMRIXMLIOItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 26/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMRIXMLIOObject.h"

@interface JMRIXMLIOItem : JMRIXMLIOObject {

}

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIXMLIOItem*)item;

# pragma mark Standard properties

@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* value;
@property (nonatomic, retain) NSString* comment;
@property (nonatomic, retain) NSString* inverted;

#pragma mark Roster properties

@property (nonatomic, retain) NSString* dccAddress;
@property (nonatomic, retain) NSString* addressLength;
@property (nonatomic, retain) NSString* roadName;
@property (nonatomic, retain) NSString* roadNumber;
@property (nonatomic, retain) NSString* mfg;
@property (nonatomic, retain) NSString* model;
@property (nonatomic, retain) NSString* maxSpeedPct;
@property (nonatomic, retain) NSString* imageFileName;
@property (nonatomic, retain) NSString* imageIconName;
@property (nonatomic, retain) NSString* functionLabels;
@property (nonatomic, retain) NSString* functionLockables;

@end
