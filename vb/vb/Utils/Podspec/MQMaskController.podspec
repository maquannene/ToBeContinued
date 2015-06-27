Pod::Spec.new do |s|

  s.name         = "MQMaskController"
  s.version      = "0.0.1"
  s.summary      = "通用型遮罩层，类似于UIPopoverController，但是更轻量级， 通过自定义contentView内容层，适用于临时气泡弹窗等"

  s.homepage     = 'https://github.com/wuhanness/MQMaskViewController'

  s.author       = { "maquan" => "maquan@kingsoft.com" }

  s.platform     = :ios
  s.platform     = :ios, "7.0"

  s.source = { :git => 'https://github.com/wuhanness/MQMaskViewController.git', :commit => 'e8bbff5d014c5049210164dcfd6b8b58b3dcb4c3'}

  s.source_files  = "MMaskViewDemo/MQMaskViewController/*.{h,m}"

  s.framework  = "UIKit"
  s.requires_arc = false

end
