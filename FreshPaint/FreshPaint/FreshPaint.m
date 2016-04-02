//
//  FreshPaint.m
//  FreshPaint
//
//  Created by Alexander Zielenski on 4/1/16.
//  Copyright © 2016 ParasiteTeam. All rights reserved.
//

#import <ParasiteRuntime/ParasiteRuntime.h>

static NSBundle *CarBundle;
static NSURL *replacementURLForName(NSString *name) {
    NSURL *url = [CarBundle URLForResource:name withExtension:@"car"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:NULL]) {
        return url;
    }
    
    return nil;
}

ZKSwizzleInterface(_FPFacet, CUIThemeFacet, NSObject)
@implementation _FPFacet

+ (unsigned long long)themeNamed:(NSString *)name forBundleIdentifier:(NSString *)bndle error:(NSError **)err {
    if ([bndle isEqualToString:@"com.apple.systemappearance"] &&
        replacementURLForName(name)) {
        bndle = CarBundle.bundleIdentifier;
    }
    return ZKOrig(unsigned long long, name, bndle, err);
}

PSInitialize {
    // Copy SystemAppearance.bundle to /Library/Parasite/CarThemes.bundle
    // and change the bundle identifier. Then put in any car
    // files you want to replace and they will be patched at runtime
    // for the original ones in the system.
    CarBundle = [NSBundle bundleWithPath:@"/Library/Parasite/CarThemes.bundle"];
}

@end
