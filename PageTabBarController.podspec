#
# Be sure to run `pod lib lint SimpleTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PageTabBarController"
  s.version          = "1.3.0"
  s.summary          = "iOS Custom Tab Bar with Tabs Collapsible."
  s.description      = "A material TabBarController with Android-liked Tabs Collapsible."
  s.homepage         = "https://github.com/MingLoan/PageTabBarController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mingloan" => "mingloanchan@gmail.com" }
  s.source           = { :git => "https://github.com/MingLoan/PageTabBarController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mingloan'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'sources/*'

end
