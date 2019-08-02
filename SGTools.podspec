#
# Be sure to run `pod lib lint SGTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SGTools'
  s.version          = '1.1.1'
  s.summary          = 'A short description of SGTools.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/GuiLQing/SGTools'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GuiLQing' => 'gui950823@126.com' }
  s.source           = { :git => 'https://github.com/GuiLQing/SGTools.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.subspec 'SGAudioPlayer' do |audioPlayer|
      audioPlayer.source_files = 'SGTools/Classes/SGAudioPlayer/**/*.{h,m}'
  end
  
  s.subspec 'SGVideoPlayer' do |videoPlayer|
      videoPlayer.source_files = 'SGTools/Classes/SGVideoPlayer/**/*.{h,m}'
  end
  
  s.subspec 'SGShadowView' do |shadowView|
      shadowView.source_files = 'SGTools/Classes/SGShadowView/**/*.{h,m}'
  end
      
  s.subspec 'SGSingleAudioPlayer' do |singleAudioPlayer|
      singleAudioPlayer.source_files = 'SGTools/Classes/SGSingleAudioPlayer/**/*.{h,m}'
  end
      
  s.subspec 'SGVoiceAnimationView' do |voiceAnimationView|
      voiceAnimationView.source_files = 'SGTools/Classes/SGVoiceAnimationView/**/*.{h,m}'
  end
  
  s.subspec 'SGSpeechSynthesizer' do |speechSynthesizer|
      speechSynthesizer.source_files = 'SGTools/Classes/SGSpeechSynthesizer/**/*.{h,m}'
  end
  
  s.subspec 'SGSearchController' do |searchController|
      searchController.source_files = 'SGTools/Classes/SGSearchController/**/*.{h,m}'
      searchController.resources = 'SGTools/Classes/SGSearchController/SGSearchController.bundle'
  end
  
  s.subspec 'SGTriangleView' do |triangleView|
      triangleView.source_files = 'SGTools/Classes/SGTriangleView/**/*.{h,m}'
  end
  
  s.subspec 'SGPickerView' do |pickerView|
      
      pickerView.source_files = 'SGTools/Classes/SGPickerView/*.{h,m}'
      
      pickerView.subspec 'SGBase' do |base|
          base.source_files = 'SGTools/Classes/SGPickerView/SGBase/**/*.{h,m}'
      end
      
      pickerView.subspec 'SGAddressPickerView' do |addressPickerView|
          addressPickerView.source_files = 'SGTools/Classes/SGPickerView/SGAddressPickerView/**/*.{h,m}'
          addressPickerView.resources = 'SGTools/Classes/SGPickerView/SGAddressPickerView/SGPickerView.bundle'
          addressPickerView.dependency 'SGTools/SGPickerView/SGBase'
      end
      
      pickerView.subspec 'SGDatePickerView' do |datePickerView|
          datePickerView.source_files = 'SGTools/Classes/SGPickerView/SGDatePickerView/**/*.{h,m}'
          datePickerView.dependency 'SGTools/SGPickerView/SGBase'
      end
      
      pickerView.subspec 'SGStringPickerView' do |stringPickerView|
          stringPickerView.source_files = 'SGTools/Classes/SGPickerView/SGStringPickerView/**/*.{h,m}'
          stringPickerView.dependency 'SGTools/SGPickerView/SGBase'
      end
  end
  
  s.subspec 'SGCollectionViewFlowLayout' do |collectionViewFlowLayout|
      collectionViewFlowLayout.source_files = 'SGTools/Classes/SGCollectionViewFlowLayout/**/*.{h,m}'
  end
  
  s.subspec 'SGVocabularyDictation' do |vocabularyDictation|
      vocabularyDictation.source_files = 'SGTools/Classes/SGVocabularyDictation/**/*.{h,m}'
      vocabularyDictation.resources = 'SGTools/Classes/SGVocabularyDictation/SGVocabularyDictation.bundle'
      vocabularyDictation.dependency 'Masonry'
  end
  
end
