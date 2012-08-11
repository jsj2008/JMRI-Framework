//
//  JMRIPanelXMLObject.h
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "XMLIOObject.h"

@interface XMLPanelObject : XMLIOObject

@property NSString* type;
@property NSInteger rotation;
@property NSInteger height;
@property NSInteger width;
@property NSString* item;

@end
