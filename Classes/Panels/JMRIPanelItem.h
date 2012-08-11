//
//  JMRIPanelItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@class JMRIItem;

@interface JMRIPanelItem : NSObject

@property CGPoint position;
@property NSInteger level;
@property (readonly) NSDictionary* states;
@property JMRIItem* item;
@property NSString* javaClass;
@property Boolean positionable;
@property Boolean forceControlOff;
@property Boolean hidden;
@property Boolean showTooltip;
@property Boolean editable;
@property Boolean momentary;
@property Boolean icon;

@end
