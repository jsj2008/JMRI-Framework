//
//  XMLIOFunction.h
//  JMRI Framework
//
//  Created by Randall Wood on 25/6/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLIOThrottle;

@interface XMLIOFunction : NSObject {
    
    NSUInteger identifier_;
    NSString *label;
    BOOL lockable;
    NSUInteger state_;
    XMLIOThrottle *throttle_;
    
}

- (id)initWithFunctionIdentifier:(NSUInteger)identifier;
- (id)initWithBooleanState:(BOOL)state;

@property (readonly) NSUInteger identifier;
@property (readonly) NSString* key;
@property (nonatomic) NSString* label;
@property (nonatomic) BOOL lockable;
@property (nonatomic) NSUInteger state;
@property (nonatomic) XMLIOThrottle* throttle;

@end
