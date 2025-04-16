%option noyywrap 

%x STRING 
%x COMMENT
%x MULTI_COMMENT
%x INDENTATION
%x MULTISTRING
%{
    #include"SymbolTable/symboltable.h"
    using namespace std;

    ofstream tokenOutput; //token output file 2005100_token.txt
    
    SymbolTable symboltable(10);

    map<char, string> escapechars = {{'n', "\n"},{'t', "\t"},{'\\', "\\"},{'\'', "\'"},{'a', "\a"},{'f', "\f"},{'r', "\r"},{'b', "\b"},{'v', "\v"},{'0', "\0"},{'\"', "\""},{'?', "?"}};

    string currString;

    int currIndent = 0;
    int expectedIndent = 0;
    int stringStart=0;
    int lineCount = 1;
    int errorCount = 0;

    void logFilePrint(int line, string token, string lexeme){
        cout << "Line# " << line << ": Token <" << token << "> Lexeme " << lexeme << " found"<<endl;
    }
    void tokenFilePrint(string token, string lexeme){
        tokenOutput << "<" << token << ", " << lexeme << "> "<<endl;
    }
    void addKeyword(string keyword, string token){
        logFilePrint(lineCount, token, keyword);
        tokenFilePrint(token, keyword);
    }

    void addConstCharacter(string character, string token){
        logFilePrint(lineCount, token, character);
        tokenFilePrint(token, character[1]+"");
    }

    void addConstEscapeCharacter(string character, string token){
        logFilePrint(lineCount, token, character);
        tokenFilePrint(token, escapechars[character[2]]);
    }
    void addId(string id, string token){
        logFilePrint(lineCount ,token, id);
        tokenFilePrint(token, id);
        if(!symboltable.insert(id, token)){
            cout<<"\t"<<id<<" already exists in the current ScopeTable"<<endl;
        }
        else{
            symboltable.printAllScope();
        }
    }
    void addString(string str, string token){
        logFilePrint(stringStart, token, str);
        string str2 = "";
        for(int i = 0; i < str.length(); i++){
            if(str[i] == '\\'){
                str2 += escapechars[str[i+1]];
                i++;
            }
            else{
                str2 += str[i];
            }
        }
        tokenFilePrint(token, str2);
    }
    void addComment(string comment){
        logFilePrint(stringStart, "COMMENT", comment);
    }
    void error(int line, string symbol, string erorrMessage) {
        cout << "Error at line# " << line << ": " << erorrMessage << " " << symbol << endl;
        errorCount++;
    }
    void indentError(int line, int spaceCount,int expectedIndent){
        cout<<"Line# "<<line<<": Warning, "<<expectedIndent<<" of spaces needed but got "<<spaceCount<<" spaces."<<endl;
    }
    void handleSpace(){
        int spaceCount = 0;
        for(int i=0;i<strlen(yytext);i++){
            if(yytext[i]==' ') spaceCount++;
            else if(yytext[i]=='\t') spaceCount+=4;
            else if(yytext[i]=='\v') spaceCount+=2;
        }
        if(spaceCount!=expectedIndent){
            indentError(lineCount, spaceCount, expectedIndent);
        }
        else{currIndent=spaceCount;}
    }
%}

DIGIT [0-9]
EXPONENT [Ee][+-]?{DIGIT}+

NEWLINE (\r)?\n

CONST_INT [0-9]+

CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?

CONST_CHARACTER \'[^\\'\n\r]|\\[nt\\'afrbv0]\'

CONST_ESCAPE_CHARACTER \'\\[nt\\'afrbv0]\'

IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*

TOO_MANY_DEMICAL_POINTS {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?
ILL_FORMAT_NUMBER {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+
INVALID_SUFFIX_OR_PREFIX  {CONST_FLOAT}+{IDENTIFIER}+
MULTI_CHAR_CONST \'.[^\'\r\n]+\' 
UNTERMINATED_CHAR \'(.|\\\')?[^\'\r\n]*

%%
[ \t\v]+ {}
{NEWLINE} {
    lineCount++;
    BEGIN INDENTATION;
}

<INDENTATION>[ \t\v]+ {
    handleSpace();
    BEGIN INITIAL;
}
<INDENTATION>. {
    yyless(0);
    BEGIN INITIAL;
}
if {addKeyword("if", "IF");}
else {addKeyword("else", "ELSE");}
for {addKeyword("for", "FOR");}
while {addKeyword("while", "WHILE");}
do {addKeyword("do", "DO");}
break {addKeyword("break", "BREAK");}
int {addKeyword("int", "INT");}
char {addKeyword("char", "CHAR");}
float {addKeyword("float", "FLOAT");}
double {addKeyword("double", "DOUBLE");}
void {addKeyword("void", "VOID");}
return {addKeyword("return", "RETURN");}
switch {addKeyword("switch", "SWITCH");}
case {addKeyword("case", "CASE");}
default {addKeyword("default", "DEFAULT");}
continue {addKeyword("continue", "CONTINUE");}

{CONST_INT} {
    addKeyword(yytext, "CONST_INT");
}

{CONST_FLOAT} {
    addKeyword(yytext, "CONST_FLOAT"); 
}
{CONST_CHARACTER} {
    addConstCharacter(yytext, "CONST_CHAR");
}

{CONST_ESCAPE_CHARACTER} {
    addConstEscapeCharacter(yytext, "CONST_CHAR");
}

[+-] {addKeyword(yytext, "ADDOP");}

[*/%] { addKeyword(yytext, "MULOP");}

"++"|"--" {addKeyword(yytext, "INCOP");}

\<|"<="|\>|">="|"=="|"!=" {
    addKeyword(yytext, "RELOP");
}
"&"|"\\|"|"^"|"<<"|">>" { addKeyword(yytext, "BITOP"); }
\= {addKeyword(yytext, "ASSIGNOP");}


"&&"|"||" {addKeyword(yytext, "LOGICOP");}

\! {
    addKeyword(yytext, "NOT");
}

\( {addKeyword(yytext, "LPAREN");}
\) {addKeyword(yytext, "RPAREN");}
\{ {
    addKeyword(yytext, "LCURL");
    symboltable.enterScope();
    expectedIndent = currIndent + 4;
}
\} {
    addKeyword(yytext, "RCURL");
    symboltable.exitScope();
    expectedIndent = currIndent - 4;
}
\[ {addKeyword(yytext, "LSQUARE");}
\] {addKeyword(yytext, "RSQUARE");}
\, {addKeyword(yytext, "COMMA");}
\; {addKeyword(yytext, "SEMICOLON");}

{IDENTIFIER} {
    addId(yytext, "ID");
}

\" {
    currString = yytext;
    stringStart = lineCount; 
    BEGIN STRING;
}

<STRING>\\{NEWLINE} {
    currString += yytext;
    lineCount++;
    BEGIN MULTISTRING;
}
<STRING>\\\" {
    currString += yytext;
} 
<STRING>[^\"\n\r] {
    currString += yytext;
}
<STRING>\" {
    currString += yytext;
    addString(currString, "STRING");
    BEGIN INITIAL;
}
<STRING>{NEWLINE} {
    error(stringStart,currString, "UNTERMINATED STRING");
    lineCount++;
    BEGIN INITIAL;
}
<MULTISTRING>\\{NEWLINE} {
    currString += yytext;
    lineCount++;
}
<MULTISTRING>\\\" {
    currString += yytext;
} 
<MULTISTRING>[^\"\n\r] {
    currString += yytext;
}
<MULTISTRING>\" {
    currString += yytext;
    addString(currString, "MULTI-LINE-STRING");
    BEGIN INITIAL;
}
<MULTISTRING>{NEWLINE} {
    error(stringStart,currString, "UNTERMINATED MULTI-LINE-STRING");
    lineCount++;
    BEGIN INITIAL;
}

"//" {
    currString = yytext;
    stringStart = lineCount;
    BEGIN COMMENT;
}

<COMMENT>. {
    currString+=yytext;
}

<COMMENT>\\{NEWLINE} {
    currString+=yytext;
    lineCount++;
}

<COMMENT>{NEWLINE} {
    addComment(currString);
    lineCount++;
    BEGIN INITIAL;
}

"/*" {
    currString = yytext;
    stringStart = lineCount; // save the line number of the start of the string
    BEGIN MULTI_COMMENT;
}

<MULTI_COMMENT>. {
    currString+=yytext;
}


<MULTI_COMMENT>{NEWLINE} {
    currString += yytext;
    lineCount++;
}


<MULTI_COMMENT>"*/" {
    currString += yytext;
    addComment(currString);
    BEGIN INITIAL;
} 

<MULTI_COMMENT><<EOF>> {
    lineCount--;
    error(stringStart, currString, "Unterminated Comment");
    symboltable.printAllScope();
    cout<<"Total lines: "<<lineCount<<endl;
    cout<<"Total errors: "<<errorCount<<endl;
    return 0;
}   

{TOO_MANY_DEMICAL_POINTS} {
    error(lineCount,yytext, "Redundant decimal points");
}
{ILL_FORMAT_NUMBER} {
    error(lineCount,yytext, "Ill formatted number");
}

{INVALID_SUFFIX_OR_PREFIX} {
    error(lineCount, yytext, "Invalid prefix or suffix");
}
{MULTI_CHAR_CONST} {
    error(lineCount, yytext, "Multi character constant error");
}

\'\' {
    error(lineCount, yytext, "Empty character constant error");
}

{UNTERMINATED_CHAR} {
    error(lineCount, yytext, "Unterminated character");
}

<<EOF>> {
    symboltable.printAllScope();
    cout<<"Total lines: "<<lineCount<<endl;
    cout<<"Total errors: "<<errorCount<<endl;
    return 0;
}

. {error(lineCount, yytext, "Unrecognized character");}
%%

int main(int argc,char *argv[]){
    if(argc != 2){
        cout<<"No input file"<<endl;
        return 0;
    }

    FILE *fin = freopen(argv[1], "r", stdin);
    tokenOutput.open("2005100_token.txt");
    freopen("2005100_log.txt", "w", stdout);
    yyin = fin;
    yylex();
    fclose(yyin);
    return 0;
}