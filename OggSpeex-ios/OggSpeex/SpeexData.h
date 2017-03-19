//
//  SpeexData.h
//  OggSpeex
//
//  Created by Mac on 16/8/4.
//  Copyright © 2016年 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeexData : NSObject

/** 文件名 */
@property (nonatomic, assign) NSString *fileName;


+ (NSString *)defaultFileName:(NSString *)fileNameNew;

- (void) startGetData;

- (NSData *) getFrame;

- (void) stopGetData;


- (void) startSetData;

- (void) setFrame:(NSData *) data;

- (void) stopSetData;


@end
