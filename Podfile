source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!
project 'ReactantUI.xcodeproj'

def shared
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'RxDataSources', '~> 3.0'
    pod 'RxOptional', '~> 3.0'
    pod 'SnapKit', '~> 4.0'
    pod 'Kingfisher', '~> 4.0'
    pod 'Result', '~> 3.0'
end

target 'Example' do
    platform :ios, '9.0'
    shared

    pod 'Reactant', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'Reactant/TableView', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'Reactant/FallbackSafeAreaInsets', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'ReactantUI', :path => './'
    pod 'ReactantLiveUI', :path => './', :configuration => 'Debug'
end

target 'Example-tvOS' do
    platform :tvos, '9.2'
    shared

    pod 'Reactant', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'Reactant/TableView', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'Reactant/FallbackSafeAreaInsets', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'tvOS'
    pod 'ReactantUI', :path => './'
    pod 'ReactantLiveUI', :path => './', :configuration => 'Debug'
end
