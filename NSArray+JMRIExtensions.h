//
//  NSArray+JMRIExtensions.h
//  JMRI Framework
//
//  Created by Randall Wood on 20/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (JMRIExtensions)

- (BOOL)containsObjectWithName:(NSString *)name;
- (NSUInteger)indexOfObjectWithName:(NSString *)name;
- (id)objectWithName:(NSString *)name;

@end
