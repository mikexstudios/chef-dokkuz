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

@test 'git deploy: push gitsubmodules' { 
  push_app 'gitsubmodules' 
}
@test 'git deploy: get output gitsubmodules' { 
  check_deploy 'gitsubmodules' 
}
@test 'git deploy: delete gitsubmodules' {
  delete_app 'gitsubmodules' 
}

@test 'git deploy: push go' { 
  push_app 'go' 
}
@test 'git deploy: get output go' { 
  check_deploy 'go' 
}
@test 'git deploy: delete go' { 
  delete_app 'go' 
}

@test 'git deploy: push java' { 
  push_app 'java' 
}
@test 'git deploy: get output java' { 
  check_deploy 'java' 
}
@test 'git deploy: delete java' { 
  delete_app 'java' 
}

@test 'git deploy: push multi' { 
  push_app 'multi' 
}
@test 'git deploy: get output multi' { 
  check_deploy 'multi' 
}
@test 'git deploy: delete multi' { 
  delete_app 'multi'
}

@test 'git deploy: push nodejs-express' { 
  push_app 'nodejs-express' 
}
@test 'git deploy: get output nodejs-express' { 
  check_deploy 'nodejs-express' 
}
@test 'git deploy: delete nodejs-express' { 
  delete_app 'nodejs-express' 
}

@test 'git deploy: push php' { 
  push_app 'php' 
}
@test 'git deploy: get output php' { 
  check_deploy 'php' 
}
@test 'git deploy: delete php' { 
  delete_app 'php' 
}

@test 'git deploy: push python-flask' { 
  push_app 'python-flask' 
}
@test 'git deploy: get output python-flask' { 
  check_deploy 'python-flask' 
}
@test 'git deploy: delete python-flask' { 
  delete_app 'python-flask' 
}

@test 'git deploy: push static' { 
  push_app 'static' 
}
@test 'git deploy: get output static' { 
  check_deploy 'static' 
}
@test 'git deploy: delete static' { 
  delete_app 'static' 
}
