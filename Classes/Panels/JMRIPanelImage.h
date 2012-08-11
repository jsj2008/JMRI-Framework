//
//  JMRIPanelImage.h
//  JMRI Framework
//
//  Created by Randall Wood on 11/8/2012.
//
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@class JMRIPanel;

@interface JMRIPanelImage : NSObject

- (id)initWithPanel:(JMRIPanel *)panel withURL:(NSURL *)url;

@property CGFloat rotation;
#if TARGET_OS_IPHONE
@property UIImage* image;
#else
@property NSImage* image;
#endif
@property float degrees;
@property float scale;
@property JMRIPanel* panel;

@end
