Pod::Spec.new do |spec|
    spec.name             = 'ReactantLiveUI'
    spec.version          = '0.0.1'
    spec.summary          = 'Live reloading of ReactantUI XML files.'
    spec.description      = <<-DESC
                            ReactantLiveUI adds live reloading capabilities to ReactantUI.
                            DESC
    spec.homepage         = 'https://github.com/Brightify/Reactant'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/Reactant.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.ios.deployment_target = '9.0'
    spec.pod_target_xcconfig = {
        'OTHER_SWIFT_FLAGS[config=Debug]' => '-D ReactantRuntime'
    }
    spec.dependency 'SWXMLHash'
    spec.dependency 'Reactant'
    spec.dependency 'Reactant/TableView'
    spec.dependency 'KZFileWatchers'
    spec.source_files = [
        'Sources/Live/**/*.swift',
        'Sources/Tokenizer/**/*.swift'
    ]
end
