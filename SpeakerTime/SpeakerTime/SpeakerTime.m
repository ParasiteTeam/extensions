//
//  SpeakerTime.m
//  SpeakerTime
//
//  Created by Alexander Zielenski on 4/1/16.
//  Copyright © 2016 ParasiteTeam. All rights reserved.
//

#import <ParasiteRuntime/ParasiteRuntime.h>
#import <CoreAudio/CoreAudio.h>

extern int AudioDeviceDuck(int arg0, int arg1);

PSHook2(int, AudioDeviceDuck, int, arg0, int, arg1) {
    return 0;
}

static int (*HALDuck)(float, AudioTimeStamp const *, float);

PSHook3(int, HALDuck, float, arg1, AudioTimeStamp const *, arg2, float, arg3) {
    return 0;
}


PSInitialize {
    HALDuck = PSFindSymbol(PSGetImageByName("/System/Library/Frameworks/CoreAudio.framework/Versions/A/CoreAudio"), "__ZN9HALDevice4DuckEfPK14AudioTimeStampf");
    PSHookFunction(HALDuck);
    PSHookFunction(AudioDeviceDuck);
}