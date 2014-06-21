#!/usr/bin/env bats

# `recipes/test_helper.rb` must be run before these tests are to set up
# these app paths and git init them. Include `recipe[dokku::test_helper]`
# in the kitchen run list.
TEST_APPS_PATH='/tmp/dokku-test/apps'

push_app() {
  APP_NAME="$1"
  check_skip $APP_NAME
  DOKKU_APP_NAME="test-$APP_NAME"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  cd $APP_PATH
  dokku delete $DOKKU_APP_NAME || true #ignore exit code
  run git push dokku master
  [ "$status" -eq 0 ]
}

check_deploy() {
  APP_NAME="$1"
  check_skip $APP_NAME
  DOKKU_APP_NAME="test-$APP_NAME"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  APP_URL=`dokku url $DOKKU_APP_NAME`
  cd $APP_PATH
  run ./check_deploy $APP_URL
  [ "$status" -eq 0 ]
}

delete_app() {
  APP_NAME="$1"
  check_skip $APP_NAME
  DOKKU_APP_NAME="test-$APP_NAME"
  run dokku delete $DOKKU_APP_NAME
  [ "$status" -eq 0 ]
}

check_skip() {
  APP_NAME="$1"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  if [ ! -d $APP_PATH ]; then
    skip 'app not found'
  fi
}

# Unfortunately, bats does not support dynamic generation of tests because it
# preprocesses "@test" statements. So we must create test stubs for each app.
# These tests cannot be condensed to single lines because of preprocessing.

@test 'push gitsubmodules' { 
  push_app 'gitsubmodules' 
}
@test 'get output gitsubmodules' { 
  check_deploy 'gitsubmodules' 
}
@test 'delete gitsubmodules' {
  delete_app 'gitsubmodules' 
}

@test 'push go' { 
  push_app 'go' 
}
@test 'get output go' { 
  check_deploy 'go' 
}
@test 'delete go' { 
  delete_app 'go' 
}

@test 'push java' { 
  push_app 'java' 
}
@test 'get output java' { 
  check_deploy 'java' 
}
@test 'delete java' { 
  delete_app 'java' 
}

@test 'push multi' { 
  push_app 'multi' 
}
@test 'get output multi' { 
  check_deploy 'multi' 
}
@test 'delete multi' { 
  delete_app 'multi'
}

@test 'push nodejs-express' { 
  push_app 'nodejs-express' 
}
@test 'get output nodejs-express' { 
  check_deploy 'nodejs-express' 
}
@test 'delete nodejs-express' { 
  delete_app 'nodejs-express' 
}

@test 'push php' { 
  push_app 'php' 
}
@test 'get output php' { 
  check_deploy 'php' 
}
@test 'delete php' { 
  delete_app 'php' 
}

@test 'push python-flask' { 
  push_app 'python-flask' 
}
@test 'get output python-flask' { 
  check_deploy 'python-flask' 
}
@test 'delete python-flask' { 
  delete_app 'python-flask' 
}

@test 'push static' { 
  push_app 'static' 
}
@test 'get output static' { 
  check_deploy 'static' 
}
@test 'delete static' { 
  delete_app 'static' 
}
