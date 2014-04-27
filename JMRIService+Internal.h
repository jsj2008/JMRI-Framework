//
//  JMRIService_JMRIService_Internal.h
//  JMRI-Framework
//
//  Created by Randall Wood on 1/5/2013.
//
//

#import <JMRI/JMRI.h>

@interface JMRIService (Internal)

#pragma mark Initialization & disposal

- (id)initWithServices:(NSSet *)services;

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService *)aService;

- (void)item:(JMRIItem *)item addedToList:(NSDictionary *)list;

@end
