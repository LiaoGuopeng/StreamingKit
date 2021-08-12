//
//  LGPAudioStreamer.m
//  AlpacaJapanese
//
//  Created by guopeng Liao on 2021/8/11.
//  Copyright © 2021 Japanese. All rights reserved.
//

#import "LGPAudioStreamer.h"
#import <STKAudioPlayer.h>

@interface LGPAudioStreamer ()<STKAudioPlayerDelegate>

@property (nonatomic, strong) STKAudioPlayer *audioStreamer;
@property (nonatomic, weak) id<LGPAudioStreamerDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation LGPAudioStreamer

+ (instancetype)sharedStreamer{
    static LGPAudioStreamer *_audioStreamer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioStreamer = [self new];
    });
    
    return _audioStreamer;
}

- (instancetype)init{
    self = [super init];
    [self initPlayer];
    
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantFuture]];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    _mCategory = AVAudioSessionCategoryPlayback;
    _mSetActiveOptions = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    return self;
}

- (void)initPlayer{
    self.audioStreamer = [[STKAudioPlayer alloc] init];
    self.audioStreamer.delegate = self;
}

- (double)duration{
    return self.audioStreamer.duration;
}

- (double)progress{
    return self.audioStreamer.progress;
}

- (void)playURL:(NSURL *)url{
    [self playURL:url delegate:self.delegate];
}

- (void)playURL:(NSURL *)url delegate:(id<LGPAudioStreamerDelegate>)delegate{
    [self playURL:url delegate:delegate rateValue:1];
}

- (void)playURL:(NSURL*)url delegate:(id<LGPAudioStreamerDelegate>)delegate rateValue:(float)rate{
    if (self.audioStreamer.state == STKAudioPlayerStateReady || self.audioStreamer.state & STKAudioPlayerStateReady) {
        [self stop];
    }
    if (self.audioStreamer.state == STKAudioPlayerStateError) {
        [self stop];
        [self initPlayer];
    }
    self.delegate = delegate;
    NSError *error = nil;
    if ( ![AVAudioSession.sharedInstance setCategory:_mCategory withOptions:_mCategoryOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    if ( ![AVAudioSession.sharedInstance setActive:YES withOptions:_mSetActiveOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
    self.audioStreamer.rate = rate;
    [self.audioStreamer playURL:url withQueueItemID:url];
}

- (void)pause{
    [self.audioStreamer pause];
}

- (void)resume{
    [self.audioStreamer resume];
}

- (void)stop{
    [self.audioStreamer stop];
}

- (void)seekToTime:(double)value{
    [self.audioStreamer seekToTime:value];
}

- (void)tick{
    if (!self.audioStreamer){

    }
    
    if (self.audioStreamer.currentlyPlayingQueueItemId == nil){
        
        return;
    }
    
    if (self.audioStreamer.duration != 0){
        if ([self.delegate respondsToSelector:@selector(audioStreamer:didChangeProgressURL:progress:andDuration:)]) {
            [self.delegate audioStreamer:self didChangeProgressURL:(NSURL *)self.audioStreamer.currentlyPlayingQueueItemId progress:self.progress andDuration:self.duration];
        }
    }
}

- (nullable NSURL *)currentlyPlayingURL{
    return (NSURL *)self.audioStreamer.currentlyPlayingQueueItemId;
}

#pragma mark - STKAudioPlayerDelegate
- (void)audioPlayer:(nonnull STKAudioPlayer *)audioStreamer didFinishBufferingSourceWithQueueItemId:(nonnull NSObject *)queueItemId {
    if ([self.delegate respondsToSelector:@selector(audioStreamer:didFinishBufferingSourceWithURL:)]) {
        [self.delegate audioStreamer:self didFinishBufferingSourceWithURL:(NSURL *)queueItemId];
    }
}

- (void)audioPlayer:(nonnull STKAudioPlayer *)audioStreamer didFinishPlayingQueueItemId:(nonnull NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    [self.delegate audioStreamer:self didFinishPlayingURL:(NSURL *)queueItemId];
}

- (void)audioPlayer:(nonnull STKAudioPlayer *)audioStreamer didStartPlayingQueueItemId:(nonnull NSObject *)queueItemId {
    [self.delegate audioStreamer:self didStartPlayingURL:(NSURL *)queueItemId];
}

- (void)audioPlayer:(nonnull STKAudioPlayer *)audioStreamer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    if (state == LGPAudioStreamerStatePlaying && [self.delegate respondsToSelector:@selector(audioStreamer:didChangeProgressURL:progress:andDuration:)]) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
    }
    [self.delegate audioStreamer:self stateChanged:(LGPAudioStreamerState)state previousState:(LGPAudioStreamerState)previousState];
}

- (void)audioPlayer:(nonnull STKAudioPlayer *)audioStreamer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    [self.delegate audioStreamer:self unexpectedError:(LGPAudioStreamerErrorCode)errorCode];
}



@end
