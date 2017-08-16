#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MCMediaPickerController.h"

@implementation MCMediaPickerController {
  FlutterResult _result;
}

- (MCMediaPickerController *)initWithResult:(FlutterResult _Nonnull)result {
  self = [super initWithMediaTypes:MPMediaTypeAnyAudio];

  if (self) {
    _result = result;

    [self setDelegate:self];
    [self setAllowsPickingMultipleItems:NO];
  }

  return self;
}

#pragma mark - MPMediaPickerControllerDelegate methods

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection * _Nonnull)mediaItemCollection {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];

    MPMediaItem *item = mediaItemCollection.items[0];

    // We are forced to convert the ID to a String because its type is UINT64, which is too big for Dart.
    _result([NSString stringWithFormat:@"%@", item.assetURL.absoluteString]);
    _result = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];

    _result(@"");
    _result = nil;
}

@end
