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

@property (readonly) NSURL* url;
@property NSUInteger height;
@property NSUInteger width;
@property Boolean showTooltips;
@property Boolean controlling;
@property NSMutableDictionary* items;
@property NSString* panelType;
@property NSUInteger levels;

@end
