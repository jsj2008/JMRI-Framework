//
//  JMRIItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMRIConstants.h"

@class JMRIService;

@protocol JMRIItem <NSObject>

#pragma mark Initialization & disposal
/** @name Initialization & disposal */

/**
 Initialize the item with a name and JMRI server.
 
 Name in JMRIItems equates to the system name, not the user name in JMRI. This is due to the need to
 use the system name for network communications, since a user name may violate some network protocols
 supported by JMRI.
 
 This initilizer will automatically trigger a query.
 
 @param name The name of the item. This must be unique.
 @param service The JMRI service that supports this item.
 */
- (id)initWithName:(NSString *)name withService:(JMRIService *)service;
/**
 Initialize the item with a JMRI server and properties.
 
 Name in JMRIItems equates to the system name, not the user name in JMRI. This is due to the need to
 use the system name for network communications, since a user name may violate some network protocols
 supported by JMRI.
 
 This initilizer will not automatically trigger a query.
 
 @param name The name of the item. This must be unique.
 @param service The JMRI service that supports this item.
 @param properties A dictionary of property values.
 */
- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties;

#pragma mark - Network communications
/** @name Network communications */

/**
 Request an update of the item's properties from JMRI.
 */
- (void)query;
/**
 Set the item's properties in JMRI.
 */
- (void)write;

#pragma mark - Properties

- (NSString *)comment;
- (void)setComment:(NSString *)comment;
- (Boolean)inverted;
- (void)setInverted:(Boolean)inverted;
- (NSString *)name;
- (void)setName:(NSString *)name;
- (JMRIService *)service;
- (void)setService:(JMRIService *)service;
- (NSString *)userName;
- (void)setUserName:(NSString *)userName;
- (NSString *)type;

@end

@interface JMRIItem : NSObject <JMRIItem> {
    
    NSUInteger _state;
    NSString *_value;

}

#pragma mark - Properties

@property NSString* comment;
@property Boolean inverted;
@property NSString* name;
@property (nonatomic, strong) JMRIService* service;
@property NSUInteger state;
@property NSString* userName;
@property NSString* value;
@property (readonly) NSString* type;
@property (readonly) NSDictionary* properties;

@end