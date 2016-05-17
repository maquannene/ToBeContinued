# MSDImageDownloadGroup

A image download group based on the SDWebImage, UIImageView download can divide groups and limit number of concurrent in group.

<p align="center"><img src="https://github.com/maquannene/MSDImageDownloadGroup/blob/master/demo.gif"/></p>

### The Problem I Use SDWebImage Category

If you use SDWebIamge/UIImageView+WebCache, you maybe written this code:

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier] autorelease];
    }

    // Here we use the new provided sd_setImageWithURL: method to load the web image
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    cell.textLabel.text = @"My Text";
    return cell;
}
```

As is known to all, UITableViewCell can be reused, so when cell is resued, the above method will be called, and imageView call `sd_setImageWithURL:...` method again. If last download is not yet complete, it will be cancel, because this code：

```objective-c
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
	//	cancel last image load
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    ...
``` 

so, we can realize that if we need load image completion by use `sd_setImageWithURL:..`, we must be sure the imageView not be reuse, but to tableViewCell, it`s reuse usually and frequently. 

### Begin Use MSDImageDownloadGroup

So, I write a new UIImageView category to load image, based on the SDWebImage, if you has same problem, you can use `UIImageView+msd_WebCache` and just modify one line of code：

```objective-c
[cell.imageView msd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
                    groupIdentifier:@"customGroupID"
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             
                          }];
```

it add your download operation into a group named "customGroupID"，and the group default `maxConcurrentDownloads` is 10, means support most 10 different URLs to download at the same time. When download URLs count is more than `maxConcurrentDownloads`, the oldest URL`s download operations will be cancel. 

Of course, you can custom create `MSDImageDownloadGroup` like this:

```objective-c
//	create customGroup
MSDImageDownloadGroup *customGroup = [[MSDImageDownloadGroup alloc] initWithGroupIdentifier:@"tableViewCellGroup"];
customGroup.maxConcurrentDownloads = 99;

//	add to MSDImageDownloadGroupManage
[[MSDImageDownloadGroupManage shareInstance] addGroup:customGroup];

//	use download group
[cell.imageView msd_setImageWithURL:@"https://xxx"
                    groupIdentifier:@"tableViewCellGroup"
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             
                          }];

```

### Installation

If you need it, 

```ruby
pod 'MSDImageDownloadGroup', :git => 'https://github.com/maquannene/MSDImageDownloadGroup.git'
```

The following I will supplement more category.
