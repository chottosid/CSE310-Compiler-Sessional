# rm -f my_parser y.tab.cpp lex.yy.cpp y.tab.hpp
# rm -f y.tab.c lex.yy.c
# bison -d -o y.tab.cpp 2005100.y
# flex -o lex.yy.cpp 2005100.l
# g++ -g -o my_parser y.tab.cpp lex.yy.cpp symboltable.cpp

# ./my_parser in.txt


rm -f mara y.tab.cpp lex.yy.cpp y.tab.hpp
rm -f y.tab.c lex.yy.c y.o l.o
bison -Wcounterexamples -d -y 2005100.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 2005100.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -lfl -o parser
echo 'All ready, running'
./parser in.txt


# -Wcounterexamples