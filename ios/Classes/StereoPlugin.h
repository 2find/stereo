#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface STStereoPlugin : NSObject <FlutterPlugin>

- (STStereoPlugin * _Nonnull)initWithChannel:(FlutterMethodChannel * _Nonnull)channel;

@end
