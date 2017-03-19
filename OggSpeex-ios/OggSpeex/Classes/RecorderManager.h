//
//  RecorderManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AQRecorder.h"
#import "Encapsulator.h"
#import "SpeexData.h"

@protocol RecordingDelegate <NSObject>

- (void)recordingFinished:(NSTimeInterval)interval;
- (void)recordingTimeout;
- (void)recordingStopped;  //录音机停止采集声音
- (void)recordingFailed:(NSString *)failureInfoString;

@optional
- (void)levelMeterChanged:(float)levelMeter;

@end

@interface RecorderManager : NSObject <EncapsulatingDelegate> {
    
    Encapsulator *encapsulator;
//    NSString *filename;
    NSDate *dateStartRecording;
    NSDate *dateStopRecording;
    NSTimer *timerLevelMeter;
    NSTimer *timerTimeout;
}

@property (nonatomic, weak)  id<RecordingDelegate> delegate;
@property (nonatomic, strong) Encapsulator *encapsulator;
@property (nonatomic, strong) NSDate *dateStartRecording, *dateStopRecording;
@property (nonatomic, strong) NSTimer *timerLevelMeter;
@property (nonatomic, strong) NSTimer *timerTimeout;

//获取对象实例
+ (RecorderManager *)sharedManager;
//开始录制
- (void)startRecording:(SpeexData *) speexData;
//结束录制
- (void)stopRecording;
//取消录制
- (void)cancelRecording;

- (NSTimeInterval)recordedTimeInterval;


@end
