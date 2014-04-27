//
//  JMRIReporter.h
//  JMRI-Framework
//
//  Created by Randall Wood on 3/8/2012.
//
//

#import "JMRIItem.h"

@interface JMRIReporter : JMRIItem

@property (copy) NSString* report;
@property (copy) NSString* lastReport;

@end
