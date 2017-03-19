//
//  Encapsulator.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "Encapsulator.h"
#import "SpeexData.h"

#define NOTIFICATION_ENCAPSULTING_OVER @"EncapsulatingOver"



@implementation Encapsulator

@synthesize moreDataInputing,isCanceled;
@synthesize speexHeader;
@synthesize mode, sampleRate, channels, nframes, vbr, streamSeraialNmber;
//@synthesize mFileName;
@synthesize delegete;

void writeInt(unsigned char *dest, int offset, int value) {
    for(int i = 0;i < 4;i++) {
        dest[offset + i]=(unsigned char)(0xff & ((unsigned int)value)>>(i*8));
    }
}

void writeString(unsigned char *dest, int offset, unsigned char *value, int length) {
    unsigned char *tempPointr = dest + offset;
    memcpy(tempPointr, value, length);
}


- (id)initWithFileName:(SpeexData *) speexData {
    if (self = [super init]) {
        _speexData = speexData;
//        [_speexData startSetData];
//        bufferData = [NSMutableData data];
        tempData = [NSMutableData data];
        pcmDatas = [NSMutableArray array];

        _isOpenSpeex = true;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(encapsulatingOver:) name:NOTIFICATION_ENCAPSULTING_OVER object:nil];
        
        [self setMode:0 sampleRate:8000 channels:1 frames:1 vbr:YES];
        
        speex_init_header(&speexHeader, sampleRate, channels, &speex_nb_mode);
        
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)resetWithFileName:(SpeexData *) speexData {
    NSLog(@"resetWithFileName()  - ");
    for(NSOperation *operation in [operationQueue operations]) {
        [operation cancel];
    }
    _speexData = speexData;
//    [_speexData startSetData];
//    [bufferData setLength:0];
    [tempData setLength:0];
    [pcmDatas removeAllObjects];
}

//- (NSMutableData *)getBufferData {
//    return bufferData;
//}

- (NSMutableArray *)getPCMDatas {
    @synchronized(pcmDatas) {
        return pcmDatas;
    }
}


- (void)setMode:(int)_mode sampleRate:(int)_sampleRate channels:(int)_channels frames:(int)_nframes vbr:(BOOL)_vbr {
    self.mode = _mode;
    self.sampleRate = _sampleRate;
    self.channels = _channels;
    self.nframes = _nframes;
    self.vbr = _vbr;
    
}

//准备Speex编码线程
- (void)prepareForEncapsulating {
    NSLog(@"prepareForEncapsulating() - 准备Speex编码线程 ...");
    self.moreDataInputing = YES;
    self.isCanceled = NO;
    encapsulationOperation = [[EncapsulatingOperation alloc] initWithParent:self];
    if (operationQueue) {
        [operationQueue addOperation:encapsulationOperation];
    }
}

- (void)inputPCMDataFromBuffer:(Byte *)buffer size:(UInt32)dataSize {

    if ( ! self.moreDataInputing) {
        return;
    }
    int packetSize = FRAME_SIZE * 2;
    @synchronized(pcmDatas) {
        [tempData appendBytes:buffer length:dataSize];
        while ([tempData length] >= packetSize) {
            @autoreleasepool {
                NSData *pcmData = [NSData dataWithBytes:[tempData bytes] length:packetSize];
                [pcmDatas addObject:pcmData];
                
                Byte *dataPtr = (Byte *)[tempData bytes];
                dataPtr += packetSize;
                tempData = [NSMutableData dataWithBytesNoCopy:dataPtr length:[tempData length] - packetSize freeWhenDone:NO];

            }
        }
    }
}


//停止Speex编码线程
- (void)stopEncapsulating:(BOOL)forceCancel {
    NSLog(@"stopEncapsulating() - 停止Speex编码线程....");
    self.moreDataInputing = NO;
    if ( ! self.isCanceled) {
        self.isCanceled = forceCancel;
    }
}

- (void)encapsulatingOver:(NSNotification *)notification {
    NSLog(@"通知 - encapsulatingOver by %@", [self description]);
    if (self.delegete) {
        [self.delegete encapsulatingOver];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end

@implementation EncapsulatingOperation

@synthesize mParent;




#pragma mark 录制声音编码关键代码

//不停从bufferData中获取数据构建paket并且修改相关计数器
- (void)main {
    NSLog(@"main ...");
    SpeexCodec *codec = [[SpeexCodec alloc] init];
    [codec open:4];     //压缩率为4
    // 开始写入Speex编码数据
    [self.mParent.speexData startSetData];
    while ( ! self.mParent.isCanceled) {
//        NSLog(@"main() - 采集音频编码...");
        if ([[self.mParent getPCMDatas] count] > 0) {
            NSData *pcmData = [[self.mParent getPCMDatas] objectAtIndex:0];
            if(self.mParent.isOpenSpeex){
                NSData *speexDataNew = [codec encode:(short *)[pcmData bytes] length:[pcmData length]/sizeof(short)];
                //将编码数据写入文件
                [self.mParent.speexData setFrame:speexDataNew];
            }else{
                //将编码数据写入文件
                [self.mParent.speexData setFrame:pcmData];
            }
            [[self.mParent getPCMDatas] removeObjectAtIndex:0];
        }
        else {
            [NSThread sleepForTimeInterval:0.02];
            
            if ( ! [self.mParent moreDataInputing]) {
                break;
            }
        }
    }
    [codec close];
    codec = nil;
    //停止写入数据
    [self.mParent.speexData stopSetData];
    if (![self.mParent isCanceled]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENCAPSULTING_OVER object:self userInfo:nil];
    }
}

//初始化NSOperation
- (id)initWithParent:(Encapsulator *)parent {
    NSLog(@"initWithParent - 初始化Speex编码线程....");
    if (self = [super init]) {
        self.mParent = parent;
    }
    return self;
}

@end
