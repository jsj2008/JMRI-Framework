//
//  JMRIPanelImage.m
//  JMRI Framework
//
//  Created by Randall Wood on 11/8/2012.
//
//

#import "JMRIPanel.h"
#import "JMRIPanelImage.h"

@implementation JMRIPanelImage

- (id)initWithPanel:(JMRIPanel *)panel withURL:(NSURL *)url {
    if ((self = [super init])) {
        self.panel = panel;
#if TARGET_OS_IPHONE
        self.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
#else
        self.image = [[NSImage alloc] initWithContentsOfURL:url];
#endif
    }
    return self;
}

@end
