#!/bin/bash

# Run flex to generate the C++ code
rm a.out
rm 2005100.cpp
flex -o 2005100.cpp 2005100.l

# Compile the generated C++ code using g++
g++ -g 2005100.cpp -lfl -o a.out

./a.out input.txt
# Display a message indicating the completion of the compilation process

# Display a message indicating the completion of the script
echo "Script execution completed."
