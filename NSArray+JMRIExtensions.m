//
//  NSArray+JMRIExtensions.m
//  JMRI Framework
//
//  Created by Randall Wood on 20/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "NSArray+JMRIExtensions.h"


@implementation NSArray (JMRIExtensions)

- (BOOL)containsObjectWithName:(NSString *)name {
	return ([self indexOfObjectWithName:name] != NSNotFound) ? YES : NO;
}

- (NSUInteger)indexOfObjectWithName:(NSString *)name {
	return [self indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
		return [[obj valueForKey:@"name"] isEqualToString:name];
	}];
}

- (id)objectWithName:(NSString *)name {
	return [self objectAtIndex:[self indexOfObjectWithName:name]];
}

@end
