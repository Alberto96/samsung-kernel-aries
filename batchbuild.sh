#!/bin/bash

make clean

echo "Building Galaxy S Stock RAM version"

./sbuild.sh galaxys 

echo "Building Galaxy S BigMem RAM version"

./sbuild.sh galaxys s 

make clean

echo "Building Vibrant Stock RAM version"

./sbuild.sh vibrant

echo "Building Vibrant BigMem RAM version"

./sbuild.sh vibrant s

make clean 

echo "Building Captivate Stock RAM version"

./sbuild.sh captivate

echo "Building Captivate BigMem RAM version"

./sbuild.sh captivate s

make clean

echo "Building Galaxy S B Stock RAM version"

./sbuild.sh galaxysb 

echo "Building Galaxy S B BigMem RAM version"

./sbuild.sh galaxysb s 

make clean

echo "Finish"
