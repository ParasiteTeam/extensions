//
//  FuckThisBlueDot.m
//  FuckThisBlueDot
//
//  Created by Timm Kandziora on 02.04.16.
//  Copyright © 2016 Timm Kandziora. All rights reserved.
//

#import <ParasiteRuntime/ParasiteRuntime.h>

@interface LPRunnable : NSObject
- (char)recentlyAdded;
@end

ZKSwizzleInterface($recentlyAdded, LPRunnable, NSObject)

@implementation $recentlyAdded

- (char)recentlyAdded
{
    return 0;
}

@end
