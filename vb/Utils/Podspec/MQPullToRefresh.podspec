Pod::Spec.new do |s|

    s.name         = "MQPullToRefresh"
    s.summary      = "下拉刷新 可自定义 正常，将要刷新，正在刷新，刷新成功，刷新失败五个状态的视图"
    s.homepage     = 'https://github.com/wuhanness/MQPullToRefresh'
    s.author       = { "maquan" => "maquan@kingsoft.com" }
    s.platform     = :ios
    s.platform     = :ios, "7.0"
    s.source       = {:git => 'https://github.com/wuhanness/MQPullToRefresh.git'}
    s.source_files = "MQPullToRefreshDemo/MQPullToRefresh/*.{h,m}"
    s.framework    = "UIKit"
    s.requires_arc = false

end