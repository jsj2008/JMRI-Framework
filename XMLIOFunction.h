//
//  XMLIOFunction.h
//  JMRI Framework
//
//  Created by Randall Wood on 25/6/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLIOFunction : NSObject {
    
    NSUInteger identifier_;
    NSString *key_;
    NSString *label;
    BOOL lockable;
    NSUInteger state;
    
}

- (id)initWithFunctionIdentifier:(NSUInteger)identifier;

@property (readonly) NSUInteger identifier;
@property (readonly, retain) NSString* key;
@property (nonatomic, retain) NSString* label;
@property (nonatomic) BOOL lockable;
@property (nonatomic) NSUInteger state;

@end
