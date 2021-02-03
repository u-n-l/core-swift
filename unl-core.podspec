Pod::Spec.new do |spec|
    spec.name         = "unl-core"
    spec.version      = ENV['LIB_VERSION']
    spec.license      = { :type => 'Apache License, Version 2.0', :file => "LICENSE" }
    spec.homepage     = "https://github.com/u-n-l/core-swift"
    spec.authors       = { "UNL Global" => "support@unl.global" }
    spec.source       = { :git => "https://github.com/u-n-l/core-swift.git", :tag => "0.0.1" }
    spec.source_files  = "core", "core/**/*.{h,m}"
    spec.summary = "The core Swift SDK for UNL Location Services"
    spec.ios.deployment_target  = '8'
    spec.osx.deployment_target  = '10.9'
    spec.swift_version = '5.0'
end
