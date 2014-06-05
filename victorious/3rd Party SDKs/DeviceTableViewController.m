// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "DeviceTableViewController.h"
#import "ChromecastDeviceController.h"
#import "VAppDelegate.h"

NSString *const CellIdForDeviceName = @"deviceName";

@interface DeviceTableViewController ()
@end

@implementation DeviceTableViewController

- (ChromecastDeviceController *)castDeviceController
{
    return [VAppDelegate sharedAppDelegate].chromecastDeviceController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  if (self.castDeviceController.isConnected == NO)
  {
    self.title = @"Connect to";
    return self.castDeviceController.deviceScanner.devices.count;
  }
  else
  {
    self.title = [NSString stringWithFormat:@"Connected to %@", self.castDeviceController.deviceName];
    return 2;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdForDeviceName = @"deviceName";
  static NSString *CellIdForReadyStatus = @"readyStatus";
  static NSString *CellIdForDisconnectButton = @"disconnectButton";
  static NSString *CellIdForPlayerController = @"playerController";

  UITableViewCell *cell;

  if (self.castDeviceController.isConnected == NO)
  {
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceName forIndexPath:indexPath];

    // Configure the cell...
    GCKDevice *device = [self.castDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.friendlyName;
    cell.detailTextLabel.text = device.modelName;
  }
  else if (self.castDeviceController.isPlayingMedia == NO)
  {
    if (indexPath.row == 0)
    {
      cell = [tableView dequeueReusableCellWithIdentifier:CellIdForReadyStatus forIndexPath:indexPath];
    }
    else
    {
      cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDisconnectButton forIndexPath:indexPath];
    }
  }
  else
  {
    if (indexPath.row == 0)
    {
      cell = [tableView dequeueReusableCellWithIdentifier:CellIdForPlayerController forIndexPath:indexPath];
      cell.textLabel.text = [self.castDeviceController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
      cell.detailTextLabel.text = [self.castDeviceController.mediaInformation.metadata stringForKey:kGCKMetadataKeySubtitle];

      // Accessory is the play/pause button.
      BOOL playing = (self.castDeviceController.playerState == GCKMediaPlayerStatePlaying ||
                      self.castDeviceController.playerState == GCKMediaPlayerStateBuffering);
      UIImage *playImage = (playing ? [UIImage imageNamed:@"pause_black.png"]
                                    : [UIImage imageNamed:@"play_black.png"]);
      CGRect frame = CGRectMake(0, 0, playImage.size.width, playImage.size.height);
      UIButton *button = [[UIButton alloc] initWithFrame:frame];
      [button setBackgroundImage:playImage forState:UIControlStateNormal];
      [button addTarget:self action:@selector(playPausePressed:) forControlEvents:UIControlEventTouchUpInside];
      cell.accessoryView = button;

      // Asynchronously load the table view image
      if (self.castDeviceController.mediaInformation.metadata.images.count > 0)
      {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        dispatch_async(queue, ^{
          GCKImage *mediaImage = [self.castDeviceController.mediaInformation.metadata.images objectAtIndex:0];

          dispatch_sync(dispatch_get_main_queue(), ^{
            UIImageView *mediaThumb = cell.imageView;
            [mediaThumb setImageWithURL:mediaImage.URL];
            [cell setNeedsLayout];
          });
        });
      }
    }
    else
    {
      cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDisconnectButton forIndexPath:indexPath];
    }
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.castDeviceController.isConnected == NO)
  {
    if (indexPath.row < self.castDeviceController.deviceScanner.devices.count)
    {
      GCKDevice *device = [self.castDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
      NSLog(@"Selecting device:%@", device.friendlyName);
      [self.castDeviceController connectToDevice:device];
    }
  }
  else if (self.castDeviceController.isPlayingMedia == YES && indexPath.row == 0)
  {
    if ([self.castDeviceController.delegate respondsToSelector:@selector(shouldPresentPlaybackController)])
    {
      [self.castDeviceController.delegate shouldPresentPlaybackController];
    }
  }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)disconnectDevice:(id)sender
{
  [self.castDeviceController disconnectFromDevice];

  // Dismiss the view.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playPausePressed:(id)sender
{
  BOOL playing = (self.castDeviceController.playerState == GCKMediaPlayerStatePlaying ||
                  self.castDeviceController.playerState == GCKMediaPlayerStateBuffering);
  [self.castDeviceController pauseCastMedia:playing];

  // change the icon.
  UIButton *button = sender;
  UIImage *playImage = (playing ? [UIImage imageNamed:@"play_black.png"] : [UIImage imageNamed:@"pause_black.png"]);
  [button setBackgroundImage:playImage forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end