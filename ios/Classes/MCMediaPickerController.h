#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MCMediaPickerController : MPMediaPickerController <MPMediaPickerControllerDelegate>

- (MCMediaPickerController *)initWithResult:(FlutterResult _Nonnull)result;

@end
