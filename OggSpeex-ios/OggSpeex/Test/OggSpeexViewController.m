//
//  OggSpeexViewController.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "OggSpeexViewController.h"
#import "RecorderManager.h"
#import "PlayerManager.h"
#import "SpeexData.h"

@interface OggSpeexViewController () <RecordingDelegate, PlayingDelegate, AVAudioRecorderDelegate>

@property (nonatomic, weak) IBOutlet UIProgressView *levelMeter;
@property (nonatomic, weak) IBOutlet UILabel *consoleLabel;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
//原生录音
@property (strong, nonatomic) IBOutlet UIView *oldRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *oldRecordButt;

@property (weak, nonatomic) IBOutlet UIButton *oldPlayButton;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, copy) NSString *fileNameC;

@property (nonatomic, strong) SpeexData *speexData;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
//@property (nonatomic, strong) SpeexData *speexDataPlay;

@property (nonatomic,strong) NSURL *tmpFile;

- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;

@end

@implementation OggSpeexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
	
    self.title = @"Speex";
    
    self.levelMeter.progress = 0;
    
    self.consoleLabel.numberOfLines = 0;
    self.consoleLabel.text = @"A demo for recording and playing speex audio.";
    
    [self.recordButton addTarget:self action:@selector(recordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.oldRecordButt addTarget:self action:@selector(luyin:) forControlEvents:UIControlEventTouchUpInside];
    [self.oldPlayButton addTarget:self action:@selector(bofang) forControlEvents:UIControlEventTouchUpInside];
    
    self.fileNameC = [SpeexData defaultFileName:@"12345"];
    
    self.speexData = [[SpeexData alloc] init];
    self.speexData.fileName = self.fileNameC;

}


-(void)luyin:(id)sender{
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    if (!_recording) {
        _recording = YES;
//        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
//        [audioSession setActive:YES error:nil];
        
        audioSession = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if(audioSession == nil)
        {
            NSLog(@"Error creating session: %@", [sessionError description]);
        }
        else{
            [audioSession setActive:YES error:nil];
        }
        [self.oldRecordButt setTitle:@"停止" forState:UIControlStateNormal];
        
//        NSDictionary *setting = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: 44100.0],AVSampleRateKey, [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey, [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey, [NSNumber numberWithInt: 2], AVNumberOfChannelsKey, [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey, [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil]; //然后直接把文件保存成.wav就好了
        
        //录音设置
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        //录音格式 无法使用
        [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        //采样率
        [settings setValue :[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];//44100.0
        //通道数
        [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //线性采样位数
        [settings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
        //音频质量,采样质量
        [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
//        _tmpFile = [NSURL fileURLWithPath:
//                   [NSTemporaryDirectory() stringByAppendingPathComponent:
//                    [NSString stringWithFormat: @"%@.%@",
//                     @"wangshuo",
//                     @"caf"]]];
        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/my.caf"];
        NSFileManager* fileManager=[NSFileManager defaultManager];
        if([fileManager removeItemAtPath:path error:nil])
        {
            NSLog(@"删除");
        }
        NSLog(@"%@",path);
       _tmpFile = [[NSURL alloc] initFileURLWithPath:path];
        
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:_tmpFile settings:settings error:nil];
        [_recorder setDelegate:self];
        [_recorder prepareToRecord];
        [_recorder record];
    } else {
        _recording = NO;
        [audioSession setActive:NO error:nil];
        [_recorder stop];
//        if (_recorder) {
//            _recorder=nil;
//        }
        [self.oldRecordButt setTitle:@"原生录音" forState:UIControlStateNormal];
    }
}




-(void)bofang{
    NSError *error;
    _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:_tmpFile
                                                      error:&error];
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    _audioPlayer.volume=1;
    if (error) {
        NSLog(@"error:%@",[error description]);
        return;
    }
    //准备播放
    [_audioPlayer prepareToPlay];
    //播放
    [_audioPlayer play];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isRecording"];
    [self removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isRecording"]) {
        [self.recordButton setTitle:(self.isRecording ? @"停止录音" : @"Speex录音") forState:UIControlStateNormal];
    }
    else if ([keyPath isEqualToString:@"isPlaying"]) {
        [self.playButton setTitle:(self.isPlaying ? @"停止播放" : @"Speex播放") forState:UIControlStateNormal];
    }
}

- (IBAction)recordButtonClicked:(id)sender {
    if (self.isPlaying) {
        return;
    }
    if ( ! self.isRecording) {
        self.isRecording = YES;
        self.consoleLabel.text = @"正在录音";
        [RecorderManager sharedManager].delegate = self;
        [[RecorderManager sharedManager] startRecording:self.speexData];
    }
    else {
        self.isRecording = NO;
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
        
    }
}

- (void) delayMethod
{
    NSLog(@"delayMethod...");
    [[RecorderManager sharedManager] stopRecording];
}


- (IBAction)playButtonClicked:(id)sender {
    if (self.isRecording) {
        return;
    }
    if ( ! self.isPlaying) {
        [PlayerManager sharedManager].delegate = nil;
        self.isPlaying = YES;
        [[PlayerManager sharedManager] playAudioWithSpeexData:self.speexData delegate:self];
    }
    else {
        self.isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
}

#pragma mark - Recording & Playing Delegate

//录制完成回调
- (void)recordingFinished:(NSTimeInterval)interval {
    self.isRecording = NO;
    self.levelMeter.progress = 0;
    //获取录制时长
//    double hour = [[RecorderManager sharedManager] recordedTimeInterval];
    //录制时长
    double aa = interval;
    NSLog(@"recordingFinished() - aa=%f", aa);
}

- (void)recordingTimeout {
    self.isRecording = NO;
    self.consoleLabel.text = @"录音超时";
    NSLog(@"recordingTimeout() - 录制超时..");
}

- (void)recordingStopped {
    self.isRecording = NO;
}

- (void)recordingFailed:(NSString *)failureInfoString {
    self.isRecording = NO;
    self.consoleLabel.text = @"录音失败";
}

- (void)levelMeterChanged:(float)levelMeter {
    self.levelMeter.progress = levelMeter;
}

- (void)playingStoped {
    self.isPlaying = NO;
}

@end
