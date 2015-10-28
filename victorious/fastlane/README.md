## Deployment

### Prerequisites
- Install [Homebrew](http://brew.sh)
- install Xcode 7.0.1 from apple developer site

### Setup

```
brew install python
pip install requests
xcode-select --switch <path_to_xcode_developer_folder>
xcode-select --install # install command line tools
```

### Build and Push

```
cd <project_dir>/VictoriousiOS/victorious
gem install fastlane && gem up fastlane
fastlane ios deploy
```
