Pod::Spec.new do |spec|
  spec.name           = "FractionalIndex"
  spec.version        = "0.0.2"
  spec.summary        = "A small utility for fractional indexing"
  spec.license        = 'MIT'
  spec.description    = <<-DESC
  For more info on fractional indexing, see this post: https://www.figma.com/blog/realtime-editing-of-ordered-sequences/
  DESC
  spec.homepage       = "https://www.github.com/varunrau/FractionalIndex"
  spec.author         = { "author" => "author@gmail.com" }
  spec.documentation_url = "https://www.github.com/varunrau/FractionalIndex"
  spec.platforms      = { :ios => "12.0", :osx => "10.15", :watchos => "6.0" }
  spec.swift_version = "5.1"
  spec.source         = { :git => "https://github.com/varunrau/FractionalIndex.git", :tag => "v#{spec.version}" }
  spec.source_files   = "Sources/FractionalIndex/**/*.swift"
  spec.xcconfig       = { "SWIFT_VERSION" => "5.1" }
end

