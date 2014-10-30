#!/usr/bin/env bats

# `recipes/test_helper.rb` must be run before these tests are to set up
# these app paths and git init them. Include `recipe[dokku::test_helper]`
# in the kitchen run list.
TEST_APPS_PATH='/tmp/dokku-test/apps'

check_deploy() {
  APP_NAME="$1"
  check_skip $APP_NAME
  DOKKU_APP_NAME="lwrp-$APP_NAME"
  APP_PATH="$TEST_APPS_PATH/$APP_NAME"
  APP_URL=`dokku url $DOKKU_APP_NAME`
  cd $APP_PATH
  run ./check_deploy $APP_URL
  [ "$status" -eq 0 ]
}

delete_app() {
  APP_NAME="$1"
  check_skip $APP_NAME
  DOKKU_APP_NAME="lwrp-$APP_NAME"
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

@test 'LWRP deploy: get output gitsubmodules' { 
  check_deploy 'gitsubmodules' 
}
@test 'LWRP deploy: delete gitsubmodules' {
  delete_app 'gitsubmodules' 
}

@test 'LWRP deploy: get output go' { 
  check_deploy 'go' 
}
@test 'LWRP deploy: delete go' { 
  delete_app 'go' 
}

@test 'LWRP deploy: get output java' { 
  check_deploy 'java' 
}
@test 'LWRP deploy: delete java' { 
  delete_app 'java' 
}

@test 'LWRP deploy: get output multi' { 
  check_deploy 'multi' 
}
@test 'LWRP deploy: delete multi' { 
  delete_app 'multi'
}

@test 'LWRP deploy: get output nodejs-express' { 
  check_deploy 'nodejs-express' 
}
@test 'LWRP deploy: delete nodejs-express' { 
  delete_app 'nodejs-express' 
}

@test 'LWRP deploy: get output php' { 
  check_deploy 'php' 
}
@test 'LWRP deploy: delete php' { 
  delete_app 'php' 
}

@test 'LWRP deploy: get output python-flask' { 
  check_deploy 'python-flask' 
}
@test 'LWRP deploy: delete python-flask' { 
  delete_app 'python-flask' 
}

@test 'LWRP deploy: get output static' { 
  check_deploy 'static' 
}
@test 'LWRP deploy: delete static' { 
  delete_app 'static' 
}
