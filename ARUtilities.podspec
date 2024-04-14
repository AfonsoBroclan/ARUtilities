Pod::Spec.new do |spec|
  spec.name         = "ARUtilities"
  spec.version      = "0.0.1"
  spec.summary      = "Helpers for iOS Development"
  spec.description  = "Different Classes, Structs, Protocols, etc to help in iOS Development"
  spec.homepage     = "https://github.com/AfonsoBroclan/ARUtilities"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Afonso Rosa" => "afrosa2@gmail.com" }
  spec.platform     = :ios, '17.2'
  spec.swift_versions = ['5.0']
  spec.source       = { :git => "https://github.com/AfonsoBroclan/ARUtilities.git", :tag => spec.version.to_s }
  spec.source_files  = "ARUtilities/Sources/**/*.{swift,h,m}"
end
