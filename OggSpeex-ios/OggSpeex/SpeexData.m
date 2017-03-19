//
//  SpeexData.m
//  OggSpeex
//
//  Created by Mac on 16/8/4.
//  Copyright © 2016年 Sense Force. All rights reserved.
//

#import "SpeexData.h"

@interface SpeexData()


@property (nonatomic, strong) NSData *dataVoice;

@property (nonatomic, assign) int size;
@property (nonatomic, assign) int offset;
@property (nonatomic, strong) NSMutableArray *mDataArray;

@property (nonatomic, assign) int totalPacks;


@end

@implementation SpeexData


- (void)startGetData
{
    NSLog(@"startGetData() - start");
    _size = 20;
    _offset = -1;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:self.fileName]){ //如果不存在
        
        NSLog(@"文件存在 %@", self.fileName);
    }else{
        NSLog(@"文件不存在");
    }
    
    _dataVoice = [NSData dataWithContentsOfFile:self.fileName];
    
    _totalPacks = (_dataVoice.length / 20) - 1;
    
    NSLog(@"startGetData() - end _totalPacks=%d", _totalPacks);
    
}


- (NSData *)getFrame
{
//    NSLog(@"getFrame() - %d", _offset);
    if(_totalPacks == _offset){
        return nil;
    }
    _offset++;
    return [_dataVoice subdataWithRange:NSMakeRange(_offset * _size, _size)];
}


- (void)stopGetData
{
    
}



#pragma mark 文件输入方法

-(void)startSetData
{
    
//    NSLog(@"startSetData - ");
    
    //判断文件是否存在，如果存在就删除
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.fileName]) {
        [fileManager removeItemAtPath:self.fileName error:nil];
    }
    
}


//设置数据
- (void)setFrame:(NSData *)data
{
    
//    NSLog(@"setFrame() - start...");
    if(data != nil){
        //写文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ( ! [fileManager fileExistsAtPath:self.fileName]) {
            [fileManager createFileAtPath:self.fileName contents:nil attributes:nil];
        }
//        NSLog(@"write data of %ld bytes to file %@", [data length], self.fileName);
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:self.fileName];
        [file seekToEndOfFile];
        [file writeData:data];
        [file closeFile];
    }
}


- (void)stopSetData
{

}


//根据文件名称获取文件全路径
+ (NSString *)defaultFileName:(NSString *)fileNameNew
{
    NSLog(@"defaultFileName() - %@",fileNameNew);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *voiceDirectory = [documentsDirectory stringByAppendingPathComponent:@"voice"];
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return [voiceDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.spx", fileNameNew]];
}



@end

