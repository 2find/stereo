#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface StereoPlugin : NSObject <FlutterPlugin>

- (StereoPlugin * _Nonnull)initWithChannel:(FlutterMethodChannel * _Nonnull)channel;

@end
