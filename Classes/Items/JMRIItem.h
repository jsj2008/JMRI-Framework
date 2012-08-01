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

@interface JMRIItem : NSObject {
    
    NSUInteger _state;

}

#pragma mark Initializers

- (id)initWithName:(NSString*)name withService:(JMRIService*)service;

#pragma mark - Communications

- (void)monitor;
- (void)stopMonitoring;
- (void)query;
- (void)write;

#pragma mark - Properties

@property NSString* comment;
@property (assign) id<JMRIItemDelegate> delegate;
@property Boolean inverted;
@property NSString* name;
@property NSUInteger state;
@property JMRIService* service;
@property NSString* userName;
@property (readonly) NSString* type;

@end