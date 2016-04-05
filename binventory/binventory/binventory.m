//
//  binventory.m
//  binventory
//
//  Created by Alexander Zielenski on 4/4/16.
//  Copyright © 2016 Alexander Zielenski. All rights reserved.
//

#import <ParasiteRuntime/ParasiteRuntime.h>
#import <CoreFoundation/CoreFoundation.h>
#import "ECStatusLabelDescription.h"
#import "SGDirWatchdog.h"

@interface NSObject (Tile)
- (void)setStatusLabel:(id)arg1 forType:(int)arg2;
- (void)removeStatusLabelForType:(int)arg1;
@end

static NSMutableArray *watchdogs = nil;
static NSArray *Trashes = nil;
ZKSwizzleInterface(DKTrashTile, DOCKTrashTile, NSObject)
@implementation DKTrashTile

- (void)dk_updateCount {
    NSUInteger x = 0;
    
    for (NSURL *url in Trashes) {
        FSRef	ref;
        CFURLGetFSRef((CFURLRef)url, &ref);
        FSCatalogInfo	catInfo;

        OSErr	err	= FSGetCatalogInfo(&ref, kFSCatInfoValence, &catInfo, NULL, NULL, NULL);
        if (err == noErr)
            x += catInfo.valence;
        
    }
    
    if (x == 0)
        [self removeStatusLabelForType:1];
    else
        [self setStatusLabel:[[ZKClass(ECStatusLabelDescription) alloc] initWithDefaultPositioningAndString:[NSString stringWithFormat:@"%lu", (unsigned long)x]] forType:1];
}

- (void)resetTrashIcon {
    ZKOrig(void);
    [self dk_updateCount];
}

- (void)changeState:(BOOL)arg1 {
    if (!watchdogs) {
        watchdogs = [[NSMutableArray alloc] init];
        Trashes = [[NSFileManager defaultManager] URLsForDirectory:NSTrashDirectory inDomains:NSUserDomainMask];
        
        
        __weak DKTrashTile *weakSelf = self;
        for (NSURL *url in Trashes) {
            SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:url.path
                                                                   update:^{
                                                                       [weakSelf dk_updateCount];
                                                                   }];
            [watchDog start];
            [watchdogs addObject:watchDog];
        }

        [self dk_updateCount];
    }
    
    ZKOrig(void, arg1);
}

- (void)dealloc {
    for (SGDirWatchdog *dog in watchdogs) {
        [dog stop];
    }
    
    Trashes = nil;
    watchdogs = nil;
    ZKOrig(void);
}

@end