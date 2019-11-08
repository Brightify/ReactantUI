source 'https://cdn.cocoapods.org/'
use_frameworks!
inhibit_all_warnings!
project 'ReactantUI.xcodeproj'

def shared
    pod 'RxSwift', '~> 5.0'
    pod 'RxCocoa', '~> 5.0'
    pod 'RxDataSources', '~> 4.0'
    pod 'RxOptional', '~> 4.0'
    pod 'SnapKit', '~> 5.0'
    pod 'Kingfisher', '~> 5.0'
    pod 'Reactant', :path => 'Dependencies/Reactant'
    pod 'Reactant/TableView', :path => 'Dependencies/Reactant'
    pod 'Reactant/FallbackSafeAreaInsets', :path => 'Dependencies/Reactant'
end

abstract_target 'LiveUI' do
    shared

    target 'LiveUI-iOS' do
        platform :ios, '10.0'

        target 'LiveUI-iOSTests' do
            pod 'Quick', '~> 2.0'
            pod 'Nimble', '~> 7.0'
            pod 'RxNimble'
            pod 'RxTest'
            pod 'iOSSnapshotTestCase'
        end
    end

    target 'LiveUI-tvOS' do
        platform :tvos, '10.0'
    end

end

target 'Example' do
    platform :ios, '10.0'
    shared

#pod 'Reactant/All-iOS', :path => '../Reactant' # :git => 'https://github.com/Brightify/Reactant.git', :branch => 'master'
#    pod 'Reactant/TableView', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'master'
#    pod 'ReactantUI', :path => './'
#    pod 'ReactantLiveUI', :path => './', :configuration => 'Debug'
end

target 'Example-tvOS' do
    platform :tvos, '10.0'
    shared

#    pod 'Reactant', :git => 'https://github.com/Brightify/Reactant.git', :branch => 'master'
#    pod 'Reactant/TableView',  :git => 'https://github.com/Brightify/Reactant.git', :branch => 'master'
#    pod 'ReactantUI', :path => './'
#    pod 'ReactantLiveUI', :path => './', :configuration => 'Debug'
end
