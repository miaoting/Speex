//
//  Encapsulator.h -- 录制
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeexCodec.h"

#define FRAME_SIZE 160 // PCM音频8khz*20ms -> 8000*0.02=160

@class EncapsulatingOperation;
@class SpeexData;

@protocol EncapsulatingDelegate <NSObject>



- (void)encapsulatingOver;

@end

@interface Encapsulator : NSObject {
    
//    NSMutableData *bufferData;  //用于ogg文件输出
    NSMutableData *tempData;    //用于输入的pcm切割剩余
    
    NSMutableArray *pcmDatas;
    

    
    //线程组
    NSOperationQueue *operationQueue;
    //任务执行者
    EncapsulatingOperation *encapsulationOperation;
    
//    NSString *mFileName;
    
    int mode;
    int sampleRate;
    int channels;
    int nframes;
    BOOL vbr;
    int streamSeraialNmber;
    
    BOOL moreDataInputing, isCanceled; //moreDataInputing是否继续封装；isCanceled，是否强制停止封装
    
    SpeexHeader speexHeader;
    
    id<EncapsulatingDelegate> delegate;
    
    
    
}
//@property (atomic, retain) NSMutableData *bufferData;
@property (assign) BOOL moreDataInputing, isCanceled;
@property (readonly) SpeexHeader speexHeader;
//@property (readonly, retain) NSString *mFileName;

@property (nonatomic,assign) BOOL isOpenSpeex;
@property (nonatomic,weak) SpeexData *speexData;

@property (nonatomic, weak) id<EncapsulatingDelegate> delegete;

@property int mode;
@property int sampleRate;
@property int channels;
@property int nframes;
@property BOOL vbr;

@property int streamSeraialNmber;

void writeInt(unsigned char *dest, int offset, int value);

void writeString(unsigned char *dest, int offset, unsigned char *value, int length);


//生成对象
- (id)initWithFileName:(SpeexData *) speexData;

- (void)resetWithFileName:(SpeexData *) speexData;

//- (NSMutableData *)getBufferData;

- (NSMutableArray *)getPCMDatas;

//设置参数
- (void)setMode:(int)_mode sampleRate:(int)_sampleRate channels:(int)_channels frames:(int)_nframes vbr:(BOOL)_vbr;

//输入新PCM数据。注意数据同步
- (void)inputPCMDataFromBuffer:(Byte *)buffer size:(UInt32)dataSize;

//停止封装。是否强制结束未完成的封装
- (void)stopEncapsulating:(BOOL)forceCancel;

//为即将开始的封装做准备
- (void)prepareForEncapsulating;

@end


//定义线程
@interface EncapsulatingOperation : NSOperation {
    

}

@property (nonatomic, retain) Encapsulator *mParent;


//初始化NSOperation
- (id)initWithParent:(Encapsulator *)parent;


@end
