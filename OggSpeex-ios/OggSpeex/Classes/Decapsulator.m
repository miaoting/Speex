//
//  Decapsulator.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "Decapsulator.h"
#import "RawAudioDataPlayer.h"

#define DESIRED_BUFFER_SIZE 4096

@interface Decapsulator()

//将ogg格式数据转换为pcm数据
- (void)convertOggToPCMWithData:(NSData *)oggData;

//packet转换完成
- (void)packetDecoded:(Byte *)decodedData size:(int)dataSize;

- (void)error:(NSString *)errorDesription;


@end

@implementation Decapsulator


- (id)initWithSpeexData:(SpeexData *) speexDataNew {
    
    if (self = [super init]) {
        //        mFileName = [NSString stringWithString:filename];
        //        NSFileManager *fileManager = [NSFileManager defaultManager];
        //        if ( ! [fileManager fileExistsAtPath:filename]) {
        //            NSLog(@"要播放的文件不存在:%@", filename);
        //        }
        operationQueue = [[NSOperationQueue alloc] init];
        _speexData = speexDataNew;
    }
    return self;
}


//播放
- (void)play {
    isPlaying = YES;
    
    if ( ! self.player) {
        self.player = [[RawAudioDataPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingingOver:) name:NOTIFICATION_PLAY_OVER object:nil];
    }
    [self.player startPlay];
    
    //启动线程
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(convertOggToPCMWithData:) object:nil];
    [[[NSOperationQueue alloc] init] addOperation:operation];
    
}

- (void)stopPlaying {
    NSLog(@"Decapsulator - stopPlaying() - ");
    isPlaying = NO;
    if (self.player) {
        [self.player stopPlay];
    }
    //    [self playingingOver:nil];
}

#pragma mark -  开始播放关键代码

//packet转换完成
- (void)packetDecoded:(Byte *)decodedData size:(int)dataSize {
    [self.player inputNewDataFromBuffer:decodedData size:dataSize];
}


//将ogg格式数据转换为pcm数据
- (void )convertOggToPCMWithData:(NSData *)oggData {
    //    NSLog(@"convertOggToPCMWithData - ");
    
    [self.speexData startGetData];
    
    NSUInteger decodedByteLength = 0;
    
    packetNo = 0;
    
    SpeexCodec *codec = [[SpeexCodec alloc] init];
    [codec open:4];
    
    int sizeNew = 20;
    short decodedBuffer[1024];
    
    
    while (YES) {
        if(!isPlaying){
            break;
        }
        //获取数据
        NSData *data = [_speexData getFrame];
        if(data == nil){
            NSLog(@"convertOggToPCMWithData() - data is null...");
            isPlaying = NO;
            break;
        }
        
        Byte *voo = (Byte *) [data bytes];
        //decode speex
        int nDecodedByte = sizeof(short) * [codec decode:voo length:sizeNew output:decodedBuffer];
        
        decodedByteLength += nDecodedByte;
        [self packetDecoded:(Byte *)decodedBuffer size:nDecodedByte];
        
        packetNo ++;
        
        // NSLog(@"convertOggToPCMWithData() - packetNo ++");
    }
    [self.speexData stopGetData];
    [codec close];
    codec = nil;
    
    
    self.player.isDataInputOver = YES;
}


- (void)error:(NSString *)errorDesription {
    NSLog(@"error:%@", errorDesription);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DecapsulatingDelegate

- (void)playingingOver:(NSNotification *)notification {
    if (self.delegate) {
        [self.delegate decapsulatingAndPlayingOver];
    }
}

@end
