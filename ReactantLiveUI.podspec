Pod::Spec.new do |spec|
    spec.name             = 'ReactantLiveUI'
    spec.version          = '0.1.3'
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

    spec.ios.deployment_target = '9.0'
    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => '-D ReactantRuntime'
    }
    spec.dependency 'Reactant', '> 1.0'
    spec.dependency 'Reactant/TableView', '> 1.0'
    spec.dependency 'RxCocoa'
    spec.source_files = [
        'Sources/Live/**/*.swift',
        'Sources/Tokenizer/**/*.swift'
    ]
end
