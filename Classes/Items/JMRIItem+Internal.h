//
//  JMRIItem+Internal.h
//  JMRI Framework
//
//  Created by Randall Wood on 20/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIItem.h"

@interface JMRIItem (Internal)

- (void)setState:(NSUInteger)state updateService:(Boolean)update;

@end
