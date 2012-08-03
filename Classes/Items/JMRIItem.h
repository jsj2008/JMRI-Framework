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
@class JMRIItem;

#pragma mark Delegation

@protocol JMRIItemDelegate<NSObject>

@required
- (void)item:(JMRIItem*)item didChangeState:(NSUInteger)state;

@end

@protocol JMRIItem <NSObject>

#pragma mark Initializers

- (id)initWithName:(NSString*)name withService:(JMRIService*)service;

#pragma mark - Communications

- (void)monitor;
- (void)stopMonitoring;
- (void)query;
- (void)write;

#pragma mark - Properties

- (NSString *)comment;
- (void)setComment:(NSString *)comment;
- (id<JMRIItemDelegate>)delegate;
- (void)setDelegate:(id<JMRIItemDelegate>)delegate;
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

}

#pragma mark - Properties

@property NSString* comment;
@property (assign) id<JMRIItemDelegate> delegate;
@property Boolean inverted;
@property NSString* name;
@property JMRIService* service;
@property NSUInteger state;
@property NSString* userName;
@property (readonly) NSString* type;

@end