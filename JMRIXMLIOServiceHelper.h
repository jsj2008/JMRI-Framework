//
//  JMRIXMLIOServiceHelper.h
//  JMRI Framework
//
//  Created by Randall Wood on 14/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMRIXMLIOObject;

@interface JMRIXMLIOServiceHelper : NSObject <NSXMLParserDelegate> {

	id delegate;
	NSMutableData* connectionData;
	NSMutableDictionary* items;
	JMRIXMLIOObject* currentItem;
	NSMutableString* currentValue;
	NSUInteger operation;
	NSString *type;
	NSString *name;
	NSURLRequest *request;

}

@property (retain) id delegate;
@property NSUInteger operation;
@property (retain) NSString *name;
@property (retain) NSString *type;
@property (retain) NSURLRequest *request;

@end

@protocol JMRIXMLIOServiceHelperDelegate

#pragma mark Required Methods

@required
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type;
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didReadItem:(JMRIXMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didWriteItem:(JMRIXMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOServiceHelperDidFinishLoading:(JMRIXMLIOServiceHelper *)helper;

@end