#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

#import "STMediaPickerController.h"
#import "StereoPlugin.h"

@implementation STStereoPlugin {
    FlutterMethodChannel *_channel;
    FlutterViewController *_flutterController;
    BOOL _isPlaying;
    AVPlayer *_player;
    FlutterResult _result;
    id _timeObserver;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"com.twofind.stereo" binaryMessenger:[registrar messenger]];
    STStereoPlugin* instance = [[STStereoPlugin alloc] initWithChannel:channel];

    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (STStereoPlugin *)initWithChannel:(FlutterMethodChannel * _Nonnull)channel {
    self = [super init];

    if (self) {
        _channel = channel;
    }

    return self;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Don't begin audio session until we need it so that it doesn't interfere with recording
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self _endAudioSession];
}

#pragma mark - FlutterPlugin methods

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    // isPlaying() method.
    if ([@"app.isPlaying" isEqualToString:call.method]) {
        result(@([self _isPlaying]));
    }
    // load() method.
    else if ([@"app.load" isEqualToString:call.method]) {
        if (call.arguments != nil) {
            if (![call.arguments isKindOfClass:[NSString class]]) {
                result([FlutterError errorWithCode:@"WRONG_FORMAT" message:@"The specified URL must be a string." details:nil]);
            }

            NSString *arg = (NSString *)call.arguments;
            if (![arg hasPrefix:@"ipod-library"]) {
                [NSString stringWithFormat:@"file://%@", arg];
            }
             
            NSURL *url = [NSURL URLWithString: arg];

            result(@([self _loadItemWithURL:url]));
        }
        else {
            result([FlutterError errorWithCode:@"NO_URL" message:@"No URL was specified." details:nil]);
        }
    }
    // pause() method.
    else if ([@"app.pause" isEqualToString:call.method]) {
        [self _pause];
        
        result(nil);
    }
    // picker() method.
    else if ([@"app.picker" isEqualToString:call.method]) {
        if (_result != nil) {
            _result([FlutterError errorWithCode:@"MULTIPLE_REQUESTS" message:@"Cannot make multiple requests." details:nil]);
            
            _result = nil;
        }
        _result = result;
        
        [self _picker];
    }
    // play() method.
    else if ([@"app.play" isEqualToString:call.method]) {
        [self _play];
        
        result(nil);
    }
    // seek() method.
    else if ([@"app.seek" isEqualToString:call.method]) {
        if (call.arguments != nil) {
            if (![call.arguments isKindOfClass:[NSNumber class]]) {
                result([FlutterError errorWithCode:@"INVALID_POSITION_TYPE" message:@"Position must be specified by an integer." details:nil]);
            }
            
            int seconds = [(NSNumber *)call.arguments intValue];
            
            [self _seek:seconds];
            
            result(nil);
        } else {
            result([FlutterError errorWithCode:@"NO_POSITION" message:@"No position was specified." details:nil]);
        }
    }
    // stop() method.
    else if ([@"app.stop" isEqualToString:call.method]) {
        [self _stop];
        
        result(nil);
    }
    // Method not implemented.
    else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Private methods

- (void)_beginAudioSession {
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    // If an error occured, display an alert.
    if (error != nil) {
        [self _showMediaPlayerAlert];
    }

    [session setActive:YES error:&error];
    if (error != nil) {
        [self _showMediaPlayerAlert];
    }

    _player = [[AVPlayer alloc] initWithPlayerItem:nil];
    
    /* TODO: Wait until Android part is implemented.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] addTarget:self action:@selector(_notifyPlayPause:)];
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] addTarget:self action:@selector(_notifyPlayPause:)];
    [[[MPRemoteCommandCenter sharedCommandCenter] togglePlayPauseCommand] addTarget:self action:@selector(_notifyPlayPause:)]; */
}

-(void)_completionHandler:(NSNotification *)notification {
    [_channel invokeMethod:@"platform.completion" arguments:nil];
}

- (void)_endAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    _player = nil;
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(bool) _isPlaying {
    return _isPlaying;
}

- (int)_loadItemWithURL:(NSURL * _Nonnull)url {

    if (_player == nil) {
      [self _beginAudioSession];
    } else {
      [self _pause];
    }

    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    
    // Set position to 00:00.
    [_channel invokeMethod:@"platform.position" arguments:@(0)];
    
    // If the asset is not playable, we return `1`. We do this at this point so
    // the player is not going in a broken state.
    if (asset.playable == 0) {
        // Set duration at 00:00.
        [_channel invokeMethod:@"platform.duration" arguments:@(0)];
        
        return 1;
    }

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];

    [_player replaceCurrentItemWithPlayerItem:item];
    
    // Send new track to the application.
    NSDictionary *metadata = [STAudioTrack toJson:url];
    [_channel invokeMethod:@"platform.currentTrack" arguments:metadata];
    
    // Send new duration to the application.
    int seconds = (int)CMTimeGetSeconds(asset.duration);
    [_channel invokeMethod:@"platform.duration" arguments:@(seconds)];
    
    // Create a weak reference to `self` so don't go into a retain cycle.
    // Credits to: https://stackoverflow.com/a/14556706/3238070
    __unsafe_unretained typeof(self) weakSelf = self;
    
    // Send position to the application every 200ms.
    CMTime interval = CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC);
    _timeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
        [weakSelf _updatePosition:time];
    }];
    
    // Add notification handler when item is done playing.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_completionHandler:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    
    return 0;
}

/* TODO: Wait until Android part is implemented. How to manage this option?
 * Parameter or compilation option?
- (MPRemoteCommandHandlerStatus)_notifyPlayPause:(MPRemoteCommandEvent *)event {
    [_channel invokeMethod:@"event.togglePlayPause" arguments:nil];

    return MPRemoteCommandHandlerStatusSuccess;
} */

- (void)_pause {
    _isPlaying = false;
    
    [_player pause];
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (void)_picker {
    STMediaPickerController *picker = [[STMediaPickerController alloc] initWithResult:_result];
    
    // If Flutter controller isn't initialized, do it.
    if (_flutterController == nil) {
        _flutterController = (FlutterViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    }
    
    // Show controller.
    [_flutterController presentViewController:picker animated:YES completion:nil];
}

- (void)_play {
    if ([_player currentItem] != nil) {
        _isPlaying = true;
        
        // Create a weak reference to `self` so don't go into a retain cycle.
        // Credits to: https://stackoverflow.com/a/14556706/3238070
        __unsafe_unretained typeof(self) weakSelf = self;
        
        // Send position to the application every 200ms.
        CMTime interval = CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC);
        _timeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
            [weakSelf _updatePosition:time];
        }];
        [_player play];
    }
}

- (void)_seek:(int)seconds {
    CMTime time = CMTimeMake(seconds, 1);
    [_player seekToTime:time];
    
    // Update position even if the player isn't playing.
    [_channel invokeMethod:@"platform.position" arguments:@(seconds)];
}

- (void)_stop {
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    
    // Reset duration and position.
    [_channel invokeMethod:@"platform.duration" arguments:@(0)];
    [_channel invokeMethod:@"platform.position" arguments:@(0)];
    
    _isPlaying = false;

    [self _endAudioSession];
}

- (void)_showMediaPlayerAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error with the music player. Please restart the app." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okButton];
    [_flutterController presentViewController:alert animated:YES completion:nil];
}

- (void)_updatePosition:(CMTime)time {
    if (_isPlaying) {
        int seconds = (int)CMTimeGetSeconds(time);
    
        [_channel invokeMethod:@"platform.position" arguments:@(seconds)];
    }
}

@end
