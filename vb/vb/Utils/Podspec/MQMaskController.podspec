Pod::Spec.new do |s|

  s.name         = "MQMaskController"
  s.summary      = "通用型遮罩层，类似于UIPopoverController，但是更轻量级， 通过自定义contentView内容层，适用于临时气泡弹窗等"
  s.homepage     = 'https://github.com/wuhanness/MQMaskViewController'
  s.author       = { "maquan" => "maquan@kingsoft.com" }
  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = {:git => 'https://github.com/wuhanness/MQMaskViewController.git', :commit => '5a79151a22c081e3486e25a1e1bce48217fe82aa'}
  s.source_files = "MMaskViewDemo/MQMaskViewController/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = false

end
