## Deployment

### Prerequisites
- Install [Homebrew](http://brew.sh)
- install Xcode 7.0.1 from apple developer site

### Setup

#### Installation

```
brew install python
pip install requests
xcode-select --switch <path_to_xcode_developer_folder>
xcode-select --install # install command line tools
```

#### Environment variables

Add the following environment variables to the `victorious/fastlane/.env` file

```
PRODUCTION_VAMS_USER = '<production_username>'
PRODUCTION_VAMS_PASSWORD = '<production_password>'
STAGING_VAMS_USER = '<staging_username>'
STAGING_VAMS_PASSWORD = '<staging_password>'
DEVELOPMENT_VAMS_USER = '<development_username>'
DEVELOPMENT_VAMS_PASSWORD = '<development_password>'
LOCAL_VAMS_USER = '<local_username>'
LOCAL_VAMS_PASSWORD = '<local_password>'
```

### Build and Push

```
cd <project_dir>/VictoriousiOS/victorious
gem install fastlane && gem up fastlane
fastlane ios deploy
```
