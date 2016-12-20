platform :ios, '8.0'

use_frameworks!

target "vb" do

# 二方
pod 'Track', :path => '../Track'
pod 'MQMaskController', :path => '../MQMaskController'
pod 'MKFImageDownloadGroup', :path => '../MXXImageDownloadGroup'

# 三方
pod 'AFNetworking', '~> 3.0'
pod 'SnapKit'
pod 'SVProgressHUD'
pod 'Kingfisher', '3.1.0'
pod 'MMDrawerController', '~> 0.5.7'
pod 'SWTableViewCell', '0.3.7'
pod 'MJExtension'
pod 'MJRefresh'
pod 'RealmSwift'

pod 'NYXImagesKit' #图片处理库
pod 'WeiboSDK', :git => 'https://github.com/sinaweibosdk/weibo_ios_sdk.git'
pod 'FDFullscreenPopGesture', :git => 'git://github.com/forkingdog/FDFullscreenPopGesture', :commit => 'da1efbf53f5fdd17090d5b30e4cd497a23827b58'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
