//
//  JMRIItem_JMRIItem_Internal.h
//  JMRI-Framework
//
//  Created by Randall Wood on 23/6/2013.
//
//

#import <JMRI/JMRI.h>

@interface JMRIReporter (Internal)

- (void)setReport:(NSString *)report withLastReport:(NSString *)lastReport updateService:(Boolean)update;

@end
