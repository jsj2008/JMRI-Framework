//
//  JMRIPanelHelper.h
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import <Foundation/Foundation.h>
#import "JMRIPanelItem.h"
#import "XMLPanelObject.h"

@class JMRIPanel;
@class JMRIPanelHelper;

// entities
extern NSString *const JMRIPanelIcon;
extern NSString *const JMRIPanelIconMaps;
extern NSString *const JMRIPanelIcons;
extern NSString *const JMRIPanelRotation;
// item states
extern NSString *const JMRIPanelStateActive;
extern NSString *const JMRIPanelStateClosed;
extern NSString *const JMRIPanelStateInactive;
extern NSString *const JMRIPanelStateInconsistent;
extern NSString *const JMRIPanelStateThrown;
extern NSString *const JMRIPanelStateUnknown;
// signal aspects
extern NSString *const JMRIPanelSignalDark;
extern NSString *const JMRIPanelSignalFlashGreen;
extern NSString *const JMRIPanelSignalFlashLunar;
extern NSString *const JMRIPanelSignalFlashRed;
extern NSString *const JMRIPanelSignalFlashYellow;
extern NSString *const JMRIPanelSignalGreen;
extern NSString *const JMRIPanelSignalHeld;
extern NSString *const JMRIPanelSignalLunar;
extern NSString *const JMRIPanelSignalRed;
extern NSString *const JMRIPanelSignalYellow;

@protocol JMRIPanelHelperDelegate

#pragma mark Required Methods

@required
- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didFailWithError:(NSError *)error;
- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didConnectWithRequest:(NSURLRequest *)request;

#pragma mark Optional Methods

@optional
- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didReadItem:(JMRIPanelItem *)item;
- (void)JMRIPanelHelperDidFinishLoading:(JMRIPanelHelper *)helper;

@end

@interface JMRIPanelHelper : NSOperation <NSXMLParserDelegate> {

    NSMutableData* connectionData;
    NSMutableDictionary* items;
    XMLPanelObject* rootElement;
    XMLPanelObject* currentElement;
    Boolean isExecuting_;
    Boolean isFinished_;

}

- (id)initWithDelegate:(id)delegate withRequest:(NSURLRequest *)request;

@property JMRIPanel* delegate;
@property NSURLRequest* request;

@end