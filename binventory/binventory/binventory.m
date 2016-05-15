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
    long x = 0;
    
    for (NSURL *url in Trashes)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/.DS_Store", url.path]])
            x -= 1;
        x += [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[url path] error:nil] count];
    }
    
    if (x <= 0)
        [self removeStatusLabelForType:1];
    else
        [self setStatusLabel:[[ZKClass(ECStatusLabelDescription) alloc] initWithDefaultPositioningAndString:[NSString stringWithFormat:@"%lu", (unsigned long)x]] forType:1];
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

static DKTrashTile *myTile = nil;

ZKSwizzleInterface(DKTile, Tile, NSObject)
@implementation DKTile

- (void)updateRect
{
    ZKOrig(void);
    if (myTile == nil)
        if ([self.className isEqualToString:@"DOCKTrashTile"])
            myTile = (DKTrashTile*)self;
}

@end

PSInitialize {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* Wait for the tile to be found */
        while (myTile == nil)
            usleep(100000);
        
        /* Set up watchdogs */
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"binventory: settting up watchdogs...");
            watchdogs = [[NSMutableArray alloc] init];
            Trashes = [[NSFileManager defaultManager] URLsForDirectory:NSTrashDirectory inDomains:NSUserDomainMask];
            
            for (NSURL *url in Trashes) {
                SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:url.path
                                                                       update:^{
                                                                           [myTile dk_updateCount];
                                                                       }];
                [watchDog start];
                [watchdogs addObject:watchDog];
            }
            [myTile dk_updateCount];
            NSLog(@"binventory: loaded...");
        });
    });
}
