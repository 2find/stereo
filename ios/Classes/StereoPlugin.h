#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface StereoPlugin : NSObject <FlutterPlugin>

- (StereoPlugin *)initWithChannel:(FlutterMethodChannel * _Nonnull)channel;

@end
