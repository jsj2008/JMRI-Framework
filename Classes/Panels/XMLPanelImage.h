//
//  XMLPanelIcon.h
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "XMLPanelObject.h"

@interface XMLPanelImage : XMLPanelObject

@property NSURL* url;
@property Float32 scale;
@property Float32 degrees;
@property NSString* name;

@end
