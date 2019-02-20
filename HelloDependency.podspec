Pod::Spec.new do |s|
  s.name         = "HelloDependency"
  s.version      = "0.0.3"
  s.summary      = "Swift Dependency Injection Framework"
  s.description  = <<-DESC
                   HelloDependency is a dependency injection framework for Swift.
                   DESC
  s.homepage     = "https://github.com/valitovaza/HelloDependency"
  s.license      = "MIT"
  s.author             = { "Azamat Valitov" => "valitov.azamat.m@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/valitovaza/HelloDependency.git", :tag => s.version }
  s.source_files  = "Sources/HelloDependency/*.swift"
  s.requires_arc = true
  s.swift_version = "4.2"

  # UIKitDependencyHelper Extensions
      s.subspec 'UIKitDependencyHelper' do |sp|
      sp.source_files  = "Sources/UIKitDependencyHelper/*.swift"
  end

end
