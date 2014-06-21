# Define list of apps to test as array of strings or '*' to test all apps.
# By default, we specify a small list to keep testing fast.
default['dokku']['test_deploy']['apps'] = ['go', 'python-flask']
