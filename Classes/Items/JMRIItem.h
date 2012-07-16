//
//  JMRIItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRINetService.h"
#import "SimpleService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"
#import "JMRIConstants.h"
#import <Foundation/Foundation.h>

@class JMRIItem;

#pragma mark Delegation

@protocol JMRIItemDelegate <NSObject>

@required
- (void)item:(JMRIItem*)item didChangeState:(NSUInteger)state;

@end

#pragma mark - Class

@interface JMRIItem : NSObject {
    
    NSUInteger _state;
    
}

#pragma mark Initializers

- (id)initWithName:(NSString*)name withService:(JMRINetService*)service;

#pragma mark - Communications

- (void)read;
- (void)readFromSimpleService;
- (void)readFromWiThrottleService;
- (void)readFromXmlIOService;
- (void)write;
- (void)writeToSimpleService;
- (void)writeToWiThrottleService;
- (void)writeToXmlIOService;

#pragma mark - Properties

- (void)setState:(NSString *)state forService:(JMRINetService *)service;
- (void)setStateFromSimpleService:(NSString *)state;
- (void)setStateFromWiThrottleService:(NSString *)state;
- (void)setStateFromXmlIOService:(NSString *)state;

@property NSString* comment;
@property id<JMRIItemDelegate> delegate;
@property Boolean inverted;
@property NSString* name;
@property NSUInteger state;
@property JMRINetService* service;
@property NSString* userName;

@end

