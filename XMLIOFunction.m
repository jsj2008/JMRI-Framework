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
@synthesize key = key_;
@synthesize label;
@synthesize lockable;
@synthesize state;

- (id)initWithIdentifier:(NSUInteger)identifier {
    if ((self = [super init])) {
        identifier_ = identifier;
        key_ = [NSString stringWithFormat:@"F%lu", (unsigned long)self.identifier, nil];
        self.label = self.key;
        self.lockable = YES;
        self.state = XMLIOItemStateUnknown;
    }
    return self;
}

- (void)dealloc {
    [key_ release];
    self.label = nil;
    [super dealloc];
}

@end
