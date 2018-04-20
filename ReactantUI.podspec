Pod::Spec.new do |spec|
    spec.name             = 'ReactantUI'
    spec.version          = '0.3.0'
    spec.summary          = 'Reactant extension for UI declaration in XML'
    spec.description      = <<-DESC
                            Reactant UI is an extension for Reactant allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead, as all those declarations are precompiled into Swift. Reactant then uses the generated code to create your UI.
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
    spec.tvos.deployment_target = '9.2'

    spec.source_files = ['Sources/Common/**/*.swift', 'Sources/Runtime/**/*.swift']
    generator_name = 'reactant-ui'
    spec.preserve_paths = ['Sources/**/*', 'Package.swift', 'Package.resolved']
    spec.prepare_command = <<-CMD
        curl -Lo #{generator_name} https://github.com/Brightify/ReactantUI/releases/download/#{s.version}/#{generator_name}
        chmod +x #{generator_name}
    CMD
end
