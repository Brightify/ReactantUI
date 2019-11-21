Pod::Spec.new do |spec|
    spec.name             = 'ReactantLiveUI'
    spec.version          = '0.5.0'
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

    spec.ios.deployment_target = '10.0'
    spec.tvos.deployment_target = '10.0'

    spec.swift_version = '5.1'

    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => '-D ReactantRuntime'
    }
    spec.dependency 'Reactant', '> 1.3'
    spec.dependency 'Reactant/TableView', '> 1.3'
    spec.dependency 'Reactant/FallbackSafeAreaInsets', '> 1.3'
    spec.dependency 'RxCocoa'
    spec.source_files = [
        'Sources/Common/**/*.swift',
        'Sources/Live/**/*.{swift,h,m}',
        'Sources/Tokenizer/**/*.swift',
    ]
end
