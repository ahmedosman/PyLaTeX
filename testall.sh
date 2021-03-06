#!/usr/bin/env bash
# This script runs flake8 to test for pep8 compliance and executes all the examples and tests
# run as: testall.sh [-p COMMAND] [clean]
# Optional positional arguments
#      -c: cleans up the latex files generated
# Optional named arguments:
#      -p COMMAND: the python command that should be used, e.g. ./testall.sh -p python3
#

# Default values
python="python"

# Check if a command line argument was provided as an input argument.
while getopts ":p:ch" opt; do
  case $opt in
    p)
      python=$OPTARG
      ;;
    c)
      clean=TRUE
      ;;
    h)
      echo This runs all the tests and examples and checks for pep8 compliance
      echo
      echo Options:
      echo '   -c            cleans up the latex and pdf files generated'
      echo '   -p COMMAND    the python command that should be used to run the tests'
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check code guidelines
echo -e '\e[32mChecking for code style errors \e[0m'
if ! flake8 pylatex examples tests; then
    exit 1
fi

# Run the examples and tests
python_version=$($python --version |& sed 's|Python \(.\).*|\1|g')

if [ "$python_version" = '2' ]; then
    main_folder=python2_source
else
    main_folder=.
fi

for f in $main_folder/{tests,examples}/*.py; do
    echo -e '\e[32mTesting '$f'\e[0m'
    if ! $python $f; then
        exit 1
    fi
done

if [ "$clean" = 'TRUE' ]; then
    rm *.pdf *.log *.aux *.tex
fi
