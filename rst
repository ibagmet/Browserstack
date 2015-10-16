if [ -z "$1" ]; then
  echo "usage: rst <test file name> [<test method name>]"
  exit
fi

if [ -n "$2" ]; then
  echo "Running test '$2' '$1'."
  bundle exec ruby -I tests $1 -n $2
else
  echo "Running all tests in '$1'."
  bundle exec ruby -I tests $1
fi

# This file used to be:
#bundle exec rake test TEST=$1
