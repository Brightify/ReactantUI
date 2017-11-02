source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
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
    shared

    pod 'Reactant'
    pod 'Reactant/TableView'
    pod 'ReactantUI', :path => './'
    pod 'ReactantLiveUI', :path => './', :configuration => 'Debug'
end
