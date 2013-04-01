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

#pragma mark Initializers

- (id)initWithName:(NSString *)name withService:(JMRIService *)service;
- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties;

#pragma mark - Communications

- (void)monitor;
- (void)stopMonitoring;
- (void)query;
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

#pragma mark - Utilities

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIItem *)item;

@end