//
//  JMRIPanel.h
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import <JMRIItem.h>
#import <JMRIPanelHelper.h>

@interface JMRIPanel : JMRIItem  <JMRIPanelHelperDelegate>

@property NSCache* images;
@property (readonly) NSURL* url;
@property NSUInteger height;
@property NSUInteger width;
@property Boolean showTooltips;
@property Boolean controlling;
@property NSSet* icons;
@property NSSet* labels;
@property NSString* panelType;

@end
