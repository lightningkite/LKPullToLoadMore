#
# Be sure to run `pod lib lint LKPullToLoadMore.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LKPullToLoadMore"
  s.version          = "1.2.0"
  s.summary          = "Load More control for UITableView"
  s.description      = "Provides a 'Load More' control at the bottom of a UITableView similar to a UIRefreshControl"
  s.homepage         = "https://github.com/LightningKite/LKPullToLoadMore"
  s.license          = 'MIT'
  s.author           = { "Erik Sargent" => "erik@lightningkite.com" }
  s.source           = { :git => "https://github.com/LightningKite/LKPullToLoadMore.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Source/**/*'

  s.frameworks = 'UIKit'
end
