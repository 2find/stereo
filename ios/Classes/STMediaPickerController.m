#import <AVFoundation/AVFoundation.h>
#import <Flutter/Flutter.h>
#import <MediaPlayer/MediaPlayer.h>

#import "STMediaPickerController.h"

@implementation STAudioTrack

+ (NSDictionary *)toJson:(NSURL *)url {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    NSString *queryString = [url query];
    NSArray *components = [queryString componentsSeparatedByString:@"="];
    // File isn't in the Music Library.
    if ([components count] < 2) {
        return data;
    }
    
    id trackID = [components objectAtIndex:1];
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:trackID forProperty:MPMediaItemPropertyPersistentID]];
    
    NSArray *items = [query items];
    MPMediaItem *item = [items objectAtIndex:0];
    
    UIImage *artworkImage = [item.artwork imageWithSize:CGSizeMake(100, 100)];
    FlutterStandardTypedData *artworkData = [FlutterStandardTypedData typedDataWithBytes:UIImagePNGRepresentation(artworkImage)];
    
    [data setObject:item.albumTitle forKey:@"album"];
    [data setObject:item.artist forKey:@"artist"];
    [data setObject:artworkData forKey:@"artwork"];
    [data setObject:[url absoluteString] forKey:@"path"];
    [data setObject:item.title forKey:@"title"];
    
    return data;
}

@end

@implementation STMediaPickerController {
  FlutterResult _result;
}

- (STMediaPickerController *)initWithResult:(FlutterResult _Nonnull)result {
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
    
    NSDictionary *data = [STAudioTrack toJson:item.assetURL];
    
    _result(data);
    _result = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];

    _result([FlutterError errorWithCode:@"NO_TRACK_SELECTED" message:@"No track has been selected." details:nil]);
    _result = nil;
}

@end
