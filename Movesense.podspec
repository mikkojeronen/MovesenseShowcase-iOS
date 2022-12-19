#
# Be sure to run `pod lib lint Movesense.podspec' to ensure this is a
# valid spec before submitting.
#
# LICENSE.pdf was converted to plain text format for podspec compliance,
# the original PDF is still the only valid source for license information.
#
# The conversion was done with:
# `pdftotext -y 60 -H 650 -W 1000 -nopgbrk -layout LICENSE.pdf'
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Movesense'
  s.version          = '1.38.0'
  s.summary          = 'Library for communicating with Movesense-compatible devices over Bluetooth Low Energy'

  s.homepage         = 'http://www.movesense.com'
  s.license          = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.authors          = { 'Suunto' => 'suunto@suunto.com' }
  s.source           = { :git => 'https://bitbucket.org/suunto/movesense-mobile-lib.git' }
    
  s.platform              = 'ios'
  s.ios.deployment_target = '11.0'
  s.library               = 'stdc++', 'z'

  s.swift_version     = '4.2'
  s.source_files      = 'IOS/Movesense/include/*.h', 'IOS/Movesense/swift/*'
  s.vendored_library  = 'IOS/Movesense/Release-iphoneos/libmds.a'
end
