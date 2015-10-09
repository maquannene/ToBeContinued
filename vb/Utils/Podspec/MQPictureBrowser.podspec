Pod::Spec.new do |s|

    s.name         = "MQPictureBrowser"
    s.summary      = "简单的照片浏览器，支持放大滚动。用UICollectionview写成"
    s.homepage     = 'https://github.com/wuhanness/MQPictureBrowser'
    s.author       = { "maquan" => "maquan@kingsoft.com" }
    s.platform     = :ios
    s.platform     = :ios, "8.0"
    s.source       = {:git => 'https://github.com/wuhanness/MQPictureBrowser.git'}
    s.source_files = "MQPictureBrowserDemo/MQPictureBrowser/*.{swift}"
    s.framework    = "UIKit"
    s.requires_arc = true

end
