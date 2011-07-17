//
//  XMLIOFunction.m
//  JMRI Framework
//
//  Created by Randall Wood on 25/6/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "XMLIOFunction.h"
#import "XMLIOService.h"

@implementation XMLIOFunction

@synthesize identifier = identifier_;
@synthesize label;
@synthesize lockable;
@synthesize state = state_;

- (id)initWithFunctionIdentifier:(NSUInteger)identifier {
    if ((self = [super init])) {
        identifier_ = identifier;
        self.label = self.key;
        self.lockable = YES;
        self.state = XMLIOItemStateUnknown;
    }
    return self;
}

- (id)initWithBooleanState:(BOOL)state {
    if ((self = [super init])) {
        identifier_ = NSNotFound;
        self.state = (state) ? XMLIOItemStateActive : XMLIOItemStateInactive;
    }
    return self;
}

- (NSString *)key {
    return [NSString stringWithFormat:@"F%lu", (unsigned long)self.identifier];
}

- (void)dealloc {
    self.label = nil;
    [super dealloc];
}

@end
