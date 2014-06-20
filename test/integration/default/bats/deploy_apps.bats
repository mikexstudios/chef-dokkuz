#!/usr/bin/env bats

TEST_APPS_PATH='/tmp/dokku-test/apps'

push_app() {
  APP_NAME="$1"
  DOKKU_APP_NAME="test-$APP_NAME"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  cd $APP_PATH
  dokku delete $DOKKU_APP_NAME || true #ignore exit code
  run git push dokku master
  [ "$status" -eq 0 ]
}

check_deploy() {
  APP_NAME="$1"
  DOKKU_APP_NAME="test-$APP_NAME"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  APP_URL=`dokku url $DOKKU_APP_NAME`
  cd $APP_PATH
  run ./check_deploy $APP_URL
  [ "$status" -eq 0 ]
}

@test 'push python-flask app' {
  push_app 'python-flask'
}

@test 'get python-flask app url' {
  DOKKU_APP_NAME='test-python-flask'
  run dokku url $DOKKU_APP_NAME
  [ "$output" = 'http://test-python-flask.10.0.0.2.xip.io' ]
}

@test 'get python-flask app output' {
  check_deploy 'python-flask'
}

@test 'delete python-flask app' {
  DOKKU_APP_NAME='test-python-flask'
  run dokku delete $DOKKU_APP_NAME
  [ "$status" -eq 0 ]
}
