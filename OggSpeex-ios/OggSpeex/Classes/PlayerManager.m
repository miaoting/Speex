//
//  PlayerManager.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "PlayerManager.h"

@interface PlayerManager ()


@end

@implementation PlayerManager

@synthesize decapsulator;
@synthesize avAudioPlayer;

static PlayerManager *mPlayerManager = nil;

+ (PlayerManager *)sharedManager {
    @synchronized(self) {
        if (mPlayerManager == nil)
        {
            mPlayerManager = [[PlayerManager alloc] init];
        }
    }
    return mPlayerManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(mPlayerManager == nil)
        {
            mPlayerManager = [super allocWithZone:zone];
            return mPlayerManager;
        }
    }
    
    return nil;
}

- (id)init {
    if (self = [super init]) {
        
        //初始化播放器的时候如下设置
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }
    return self;
}



- (void)playAudioWithSpeexData:(SpeexData *) speexData delegate:(id<PlayingDelegate>)newDelegate
{
    NSLog(@"playAudioWithSpeexData - ");
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self stopPlaying];
    self.delegate = newDelegate;
    
    self.decapsulator = [[Decapsulator alloc] initWithSpeexData:speexData];
    self.decapsulator.delegate = self;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.decapsulator play];

}

- (void)stopPlaying {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    if (self.decapsulator) {
        NSLog(@"stopPlaying() - decapsulator ----");
        [self.decapsulator stopPlaying];
//        self.decapsulator.delegate = nil;   //此行如果放在上一行之前会导致回调问题
        self.decapsulator = nil;
    }
    if (self.avAudioPlayer) {
        NSLog(@"stopPlaying() - avAudioPlayer  ---");
        [self.avAudioPlayer stop];
        self.avAudioPlayer = nil;
    }
    
    [self.delegate playingStoped];
}

- (void)decapsulatingAndPlayingOver {
    [self.delegate playingStoped];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}


- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
