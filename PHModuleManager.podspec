#
#  Be sure to run `pod spec lint common.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

    spec.name             = 'PHModuleManager'
    spec.version          = "0.0.2"
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://github.com/xianfeng01010'
    spec.platform         = :ios, "9.0"
    spec.authors          = { "xinph" => "xinph@yiche.com" }
    spec.summary          = "路由中间件"
    spec.source           = { :git => "git@github.com:xianfeng01010/PHModuleManager.git", :tag => "#{spec.version}" }
    spec.source_files     = "PHModuleManager/Classes/**/*.{h,m}"

end
