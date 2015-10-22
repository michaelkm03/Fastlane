## Deployment

### Prerequisites
- Install [Homebrew](http://brew.sh)

### Setup

```
brew install python
pip install requests
xcode-select --install
```

### Build and Push

```
cd <project_dir>/VictoriousiOS/victorious
gem install fastlane && gem up fastlane
fastlane release
```
