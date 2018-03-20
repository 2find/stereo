#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

@interface STAudioTrack : NSObject

+ (NSDictionary * _Nonnull)toJson:(NSURL * _Nonnull)url;

@end

@interface STMediaPickerController : MPMediaPickerController <MPMediaPickerControllerDelegate>

- (STMediaPickerController * _Nonnull)initWithResult:(FlutterResult _Nonnull)result;

@end
