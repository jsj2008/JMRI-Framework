//
//  JMRISignalHead.m
//  JMRI Framework
//
//  Created by Randall Wood on 11/8/2012.
//
//

#import "JMRISignalHead.h"
#import "JMRIItem+Internal.h"

@implementation JMRISignalHead


- (void)queryFromJsonService:(JsonService *)service {
    [service readItem:self.name ofType:JMRITypeSignalHead];
}

- (void)queryFromSimpleService:(SimpleService *)service {
    [service send:[NSString stringWithFormat:@"SIGNALHEAD %@", self.name]];
}

- (void)writeToJsonService:(JsonService *)service {
    [service writeItem:self.name ofType:JMRITypeSignalHead state:self.state];
}

- (void)writeToSimpleService:(SimpleService *)service {
    NSString* state;
    switch (self.state) {
        case JMRISignalAppearanceDark:
            state = @"DARK";
            break;
        case JMRISignalAppearanceFlashGreen:
            state = @"FLASHGREEN";
            break;
        case JMRISignalAppearanceFlashLunar:
            state = @"FLASHLUNAR";
            break;
        case JMRISignalAppearanceFlashRed:
            state = @"FLASHRED";
            break;
        case JMRISignalAppearanceFlashYellow:
            state = @"FLASHYELLOW";
            break;
        case JMRISignalAppearanceGreen:
            state = @"GREEN";
            break;
        case JMRISignalAppearanceLunar:
            state = @"LUNAR";
            break;
        case JMRISignalAppearanceRed:
            state = @"RED";
            break;
        case JMRISignalAppearanceYellow:
            state = @"YELLOW";
            break;
        default:
            return; // state is invalid so don't send it
            break;
    }
    [service send:[NSString stringWithFormat:@"SIGNALHEAD %@ %@", self.name, state]];
}

@end