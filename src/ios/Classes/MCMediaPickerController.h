#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MCAudioTrack : NSObject

+ (NSDictionary * _Nonnull)toJson:(NSURL * _Nonnull)url;

@end

@interface MCMediaPickerController : MPMediaPickerController <MPMediaPickerControllerDelegate>

- (MCMediaPickerController * _Nonnull)initWithResult:(FlutterResult _Nonnull)result;

@end
