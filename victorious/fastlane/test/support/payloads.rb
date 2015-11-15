module Payloads
  PATH_TO_ALL_PAYLOADS    = File.join(File.dirname(__FILE__), 'payloads')
  APPS_TO_BUILD_JSON_PATH = File.join(PATH_TO_ALL_PAYLOADS, 'apps_to_build.json')
  APP_BY_BUILD_NAME       = File.join(PATH_TO_ALL_PAYLOADS, 'app_by_build_name.json')
  SUCCESSFUL_LOGIN_PATH   = File.join(PATH_TO_ALL_PAYLOADS, 'successful_login.json')
end
