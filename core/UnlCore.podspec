Pod::Spec.new do |spec|
    spec.name         = "UnlCore"
    spec.version      = "0.0.1"
    spec.license      = { :type => 'Apache License, Version 2.0', :file => "LICENSE" }
    spec.homepage     = "https://github.com/u-n-l/core-swift"
    spec.authors       = { "UNL Global" => "support@unl.global" }
    spec.source       = { :git => "https://github.com/u-n-l/core-swift.git", :tag => "0.0.1" }
    spec.source_files  = "core", "core/**/*.{h,m}"
    spec.summary      = "Convert a UNL locationId to/from a latitude/longitude point, retrieve the bounds of a UNL cell or the UNL grid lines."
end
