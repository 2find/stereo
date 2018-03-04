#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

#import "StereoPlugin.h"

@implementation StereoPlugin {
    FlutterMethodChannel *_channel;
    BOOL _isPlaying;
    AVPlayer *_player;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"com.twofind.stereo" binaryMessenger:[registrar messenger]];
    StereoPlugin* instance = [[StereoPlugin alloc] initWithChannel:channel];

    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
}

- (StereoPlugin *)initWithChannel:(FlutterMethodChannel * _Nonnull)channel {
    self = [super init];

    if (self) {
        _channel = channel;
    }

    return self;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Begin audio session.
    [self _beginAudioSession];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self _endAudioSession];
}

#pragma mark - FlutterPlugin methods

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
    // load() method.
    if ([@"app.load" isEqualToString:call.method]) {
        if (call.arguments != nil) {
            if (![call.arguments isKindOfClass:[NSString class]]) {
                result([FlutterError errorWithCode:@"WRONG_FORMAT" message:@"The specified URL must be a string." details:nil]);
            }

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", (NSString *)call.arguments]];

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
    // play() method.
    else if ([@"app.play" isEqualToString:call.method]) {
        [self _play];
        
        result(nil);
    }
    else if ([@"app.togglePlaying" isEqualToString:call.method]) {
        result(@([self _togglePlayPause]));
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
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [[[MPRemoteCommandCenter sharedCommandCenter] pauseCommand] addTarget:self action:@selector(_notifyPlayPause:)];
    [[[MPRemoteCommandCenter sharedCommandCenter] playCommand] addTarget:self action:@selector(_notifyPlayPause:)];
    [[[MPRemoteCommandCenter sharedCommandCenter] togglePlayPauseCommand] addTarget:self action:@selector(_notifyPlayPause:)];
}

- (void)_endAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    _player = nil;
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (int)_loadItemWithURL:(NSURL * _Nonnull)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    
    // If the asset is not playable, we return `1`. We do this at this point so
    // the player is not going in a broken state.
    if (asset.playable == 0) {
        return 1;
    }

    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];

    [_player replaceCurrentItemWithPlayerItem:item];
    
    return 0;
}

- (MPRemoteCommandHandlerStatus)_notifyPlayPause:(MPRemoteCommandEvent *)event {
    [_channel invokeMethod:@"event.togglePlayPause" arguments:nil];

    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)_pause {
    [_player pause];
    
    _isPlaying = false;
}

- (void)_play {
    [_player play];
    
    _isPlaying = true;
}

- (void)_showMediaPlayerAlert {
    FlutterViewController *controller = (FlutterViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was an error with the music player. Please restart the app." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okButton];
    [controller presentViewController:alert animated:YES completion:nil];
}

- (BOOL)_togglePlayPause {
    if (_isPlaying) {
        [_player pause];
    }
    else {
        [_player play];
    }

    _isPlaying = !_isPlaying;

    return _isPlaying;
}

@end
