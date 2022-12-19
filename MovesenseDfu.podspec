#
# Be sure to run `pod lib lint MovesenseDfu.podspec' to make sure this is a
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

  s.name             = 'MovesenseDfu'
  s.version          = '0.1'
  s.summary          = 'Device Firmware Upgrade (DFU) framework for Movesense based sensors.'

  s.homepage         = 'http://www.movesense.com'
  s.license          = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.authors          = { 'Suunto' => 'suunto@suunto.com' }
  s.source           = { :git => 'https://bitbucket.org/suunto/movesense-mobile-lib.git', :tag => 'v0.1' }
    
  s.platform              = 'ios'
  s.ios.deployment_target = '10.0'
    
  s.swift_version     = '5.0'
  s.source_files      = 'IOS/MovesenseDfu/MovesenseDfu/*.h', 'IOS/MovesenseDfu/MovesenseDfu/*.swift'
    
  s.dependency 'iOSDFULibrary', '4.4.2'
end
