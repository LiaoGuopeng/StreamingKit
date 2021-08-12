//
//  LGPAudioStreamer.h
//  AlpacaJapanese
//
//  Created by guopeng Liao on 2021/8/11.
//  Copyright © 2021 Japanese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LGPAudioStreamer;
NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSInteger, LGPAudioStreamerState)
{
    LGPAudioStreamerStateReady,
    LGPAudioStreamerStateRunning = 1,
    LGPAudioStreamerStatePlaying = (1 << 1) | LGPAudioStreamerStateRunning,
    LGPAudioStreamerStateBuffering = (1 << 2) | LGPAudioStreamerStateRunning,
    LGPAudioStreamerStatePaused = (1 << 3) | LGPAudioStreamerStateRunning,
    LGPAudioStreamerStateStopped = (1 << 4),
    LGPAudioStreamerStateError = (1 << 5),
    LGPAudioStreamerStateDisposed = (1 << 6)
};

typedef NS_ENUM(NSInteger, LGPAudioStreamerErrorCode)
{
    LGPAudioStreamerErrorNone = 0,
    LGPAudioStreamerErrorDataSource,
    LGPAudioStreamerErrorStreamParseBytesFailed,
    LGPAudioStreamerErrorAudioSystemError,
    LGPAudioStreamerErrorCodecError,
    LGPAudioStreamerErrorDataNotFound,
    LGPAudioStreamerErrorOther = 0xffff
};

@protocol LGPAudioStreamerDelegate <NSObject>

- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer didStartPlayingURL:(NSURL *)url;

- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer stateChanged:(LGPAudioStreamerState)state previousState:(LGPAudioStreamerState)previousState;

- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer didFinishPlayingURL:(NSURL*)url;

- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer unexpectedError:(LGPAudioStreamerErrorCode)errorCode;

@optional
- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer didFinishBufferingSourceWithURL:(NSURL *)url;

- (void)audioStreamer:(LGPAudioStreamer *)audioStreamer didChangeProgressURL:(NSURL *)url progress:(double)progress andDuration:(double)duration;
@end

@interface LGPAudioStreamer : NSObject

@property (readonly) double duration;
@property (readonly) double progress;


@property (nonatomic) AVAudioSessionCategory mCategory;
@property (nonatomic) AVAudioSessionSetActiveOptions mSetActiveOptions;
@property (nonatomic) AVAudioSessionCategoryOptions mCategoryOptions;

+ (instancetype)sharedStreamer;

- (void)playURL:(NSURL*)url;

- (void)playURL:(NSURL*)url delegate:(id<LGPAudioStreamerDelegate>)delegate;

- (void)playURL:(NSURL*)url delegate:(id<LGPAudioStreamerDelegate>)delegate rateValue:(float)rate;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)seekToTime:(double)value;

- (nullable NSURL *)currentlyPlayingURL;

@end

NS_ASSUME_NONNULL_END
