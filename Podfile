platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!
xcodeproj 'Hangdogger.xcodeproj'

def main_pods
    pod 'RealmSwift'
    pod 'Swinject', '2.0.0-beta.2'
    pod 'SwinjectStoryboard', '1.0.0-beta.2'
    pod 'HTTPStatusCodes', '~> 3.1.0'
    pod 'ReactiveSwift', '1.0.0-alpha.2'

    pod 'Moya', '8.0.0-beta.2'
    pod 'Moya/ReactiveCocoa'

    pod 'ObjectMapper', '2.1.0'
end

target 'Hangdogger' do
    main_pods

    target 'HangdoggerTests' do
        inherit! :search_paths
        pod 'Quick'
        pod 'Nimble'
    end
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0' # or '3.0'
        end
    end
end
