Pod::Spec.new do |spec|
    spec.name             = 'SanAndreas'
    spec.version          = '0.1.1'
    spec.summary          = 'Live reloading of ReactantUI XML files.'
    spec.description      = <<-DESC
                            ReactantLiveUI adds live reloading capabilities to ReactantUI.
                            DESC
    spec.homepage         = 'http://reactant.tech'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/ReactantUI.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true
    spec.osx.deployment_target = '10.11'
    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => '-D SanAndreas'
    }
    spec.dependency 'Reactant', '> 1.0'
    spec.dependency 'RxCocoa'
    spec.source_files = [
        'Sources/Tokenizer/**/*.swift',
    ]
end
