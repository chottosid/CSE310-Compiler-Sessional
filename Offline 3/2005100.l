%option noyywrap 


%x STRING 
%x COMMENT
%x MULTI_COMMENT
%x MULTISTRING
%{
    #include <bits/stdc++.h>
    #include"symboltable.h"
    #include "y.tab.h"
    using namespace std;

    //ofstream tokenOutput; //token output file 2005100_token.txt
    
    extern SymbolTable* symboltable;
    //extern int error_count;
    extern void error(string error);
    extern YYSTYPE yylval;
    map<char, string> escapechars = {{'n', "\n"},{'t', "\t"},{'\\', "\\"},{'\'', "\'"},{'a', "\a"},{'f', "\f"},{'r', "\r"},{'b', "\b"},{'v', "\v"},{'0', "\0"},{'\"', "\""},{'?', "?"}};

    string currString = "";
    int currIndent = 0;
    int expectedIndent = 0;
    int stringStart=0;
    int line_count = 1;
    int error_count = 0;

    // void logFilePrint(int line, string token, string lexeme){
    //     cout << "Line# " << line << ": Token <" << token << "> Lexeme " << lexeme << " found"<<endl;
    // }
    // // void tokenFilePrint(string token, string lexeme){
    // //     tokenOutput << "<" << token << ", " << lexeme << "> "<<endl;
    // // }
    // void addKeyword(string keyword, string token){
    //     logFilePrint(line_count, token, keyword);
    //     tokenFilePrint(token, keyword);
    // }

    // void addConstCharacter(string character, string token){
    //     logFilePrint(line_count, token, character);
    //     tokenFilePrint(token, character[1]+"");
    // }

    // void addConstEscapeCharacter(string character, string token){
    //     logFilePrint(line_count, token, character);
    //     tokenFilePrint(token, escapechars[character[2]]);
    // }
    // void addId(string id, string token){
    //     logFilePrint(line_count ,token, id);
    //     tokenFilePrint(token, id);
    //     if(!symboltable.insert(id, token)){
    //         cout<<"\t"<<id<<" already exists in the current ScopeTable"<<endl;
    //     }
    //     else{
    //         symboltable.printAllScope();
    //     }
    // }
    // void addString(string str, string token){
    //     logFilePrint(stringStart, token, str);
    //     string str2 = "";
    //     for(int i = 0; i < str.length(); i++){
    //         if(str[i] == '\\'){
    //             str2 += escapechars[str[i+1]];
    //             i++;
    //         }
    //         else{
    //             str2 += str[i];
    //         }
    //     }
    //     tokenFilePrint(token, str2);
    // }
    // void addComment(string comment){
    //     logFilePrint(stringStart, "COMMENT", comment);
    // }
    // void error(int line, string symbol, string erorrMessage) {
    //     cout << "Error at line# " << line << ": " << erorrMessage << " " << symbol << endl;
    //     error_count++;
    // }
    // void indentError(int line, int spaceCount,int expectedIndent){
    //     cout<<"Line# "<<line<<": Warning, "<<expectedIndent<<" of spaces needed but got "<<spaceCount<<" spaces."<<endl;
    // }
    // void handleSpace(){
    //     int spaceCount = 0;
    //     for(int i=0;i<strlen(yytext);i++){
    //         if(yytext[i]==' ') spaceCount++;
    //         else if(yytext[i]=='\t') spaceCount+=4;
    //         else if(yytext[i]=='\v') spaceCount+=2;
    //     }
    //     if(spaceCount!=expectedIndent){
    //         indentError(line_count, spaceCount, expectedIndent);
    //     }
    //     else{currIndent=spaceCount;}
    // }
%}

DIGIT [0-9]
EXPONENT {DIGIT}[Ee][+-]?{DIGIT}+

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
    line_count++;
    //BEGIN INDENTATION;
}
if {
    yylval.symbol = new SymbolInfo(yytext, "IF","IF",line_count,line_count,true,{});
    return IF;
}
else {
    yylval.symbol = new SymbolInfo(yytext,"ELSE","ELSE",line_count,line_count,true,{});
    return ELSE;
}
while {
    yylval.symbol = new SymbolInfo(yytext, "WHILE","WHILE",line_count,line_count,true,{});
    return WHILE;
}
for {
    yylval.symbol = new SymbolInfo(yytext, "FOR","FOR",line_count,line_count,true,{});
    return FOR;
}
int {
    yylval.symbol = new SymbolInfo(yytext, "INT","INT",line_count,line_count,true,{});
    return INT;
}
float {
    yylval.symbol = new SymbolInfo(yytext, "FLOAT","FLOAT",line_count,line_count,true,{});
    return FLOAT;
}
char {
    yylval.symbol = new SymbolInfo(yytext, "CHAR","CHAR",line_count,line_count,true,{});
    return CHAR;
}
void {
    yylval.symbol = new SymbolInfo(yytext, "VOID","VOID",line_count,line_count,true,{});
    return VOID;
}
return {
    yylval.symbol = new SymbolInfo(yytext, "RETURN","RETURN",line_count,line_count,true,{});
    return RETURN;
}
switch {
    yylval.symbol = new SymbolInfo(yytext, "SWITCH","SWITCH",line_count,line_count,true,{});
    return SWITCH;
}
case {
    yylval.symbol = new SymbolInfo(yytext, "CASE","CASE",line_count,line_count,true,{});
    return CASE;
}
break {
    yylval.symbol = new SymbolInfo(yytext, "BREAK","BREAK",line_count,line_count,true,{});
    return BREAK;
}
continue {
    yylval.symbol = new SymbolInfo(yytext, "CONTINUE","CONTINUE",line_count,line_count,true,{});
    return CONTINUE;
}
default {
    yylval.symbol = new SymbolInfo(yytext, "DEFAULT","DEFAULT",line_count,line_count,true,{});
    return DEFAULT;
}
println {
    yylval.symbol = new SymbolInfo(yytext, "PRINTLN","PRINTLN",line_count,line_count,true,{});
    return PRINTLN;
}
{CONST_INT} {
    yylval.symbol = new SymbolInfo(yytext, "CONST_INT","CONST_INT",line_count,line_count,true,{});
    return CONST_INT;
}

{CONST_FLOAT} {
    yylval.symbol = new SymbolInfo(yytext, "CONST_FLOAT","CONST_FLOAT",line_count,line_count,true,{});
    return CONST_FLOAT;
}
{CONST_CHARACTER} {
    yylval.symbol = new SymbolInfo(yytext, "CONST_CHAR","CONST_CHAR",line_count,line_count,true,{});
    return CONST_CHAR;
}

{CONST_ESCAPE_CHARACTER} {
    yylval.symbol = new SymbolInfo(yytext, "CONST_CHAR","CONST_CHAR",line_count,line_count,true,{});
    return CONST_CHAR;
}

[+-] {
    yylval.symbol = new SymbolInfo(yytext, "ADDOP", "ADDOP",line_count,line_count,true,{});
    return ADDOP;
}

[*/%] { yylval.symbol = new SymbolInfo(yytext, "MULOP", "MULOP",line_count,line_count,true,{});
    return MULOP;}

"++" {yylval.symbol = new SymbolInfo(yytext, "INCOP", "INCOP",line_count,line_count,true,{});
     return INCOP;}
"--" {yylval.symbol = new SymbolInfo(yytext, "DECOP", "DECOP",line_count,line_count,true,{});
return DECOP;}

\<|"<="|\>|">="|"=="|"!=" {
    yylval.symbol = new SymbolInfo(yytext, "RELOP", "RELOP",line_count,line_count,true,{});
    return RELOP;
}
"&"|"\\|"|"^"|"<<"|">>" { yylval.symbol = new SymbolInfo(yytext, "BITOP", "BITOP",line_count,line_count,true,{});
 return BITOP;}
\= {yylval.symbol = new SymbolInfo(yytext, "ASSIGNOP", "ASSIGNOP",line_count,line_count,true,{});
 return ASSIGNOP;}


"&&"|"||" {yylval.symbol = new SymbolInfo(yytext, "LOGICOP", "LOGICOP",line_count,line_count,true,{});
 return LOGICOP;}

\! {
    yylval.symbol = new SymbolInfo(yytext, "NOT", "NOT",line_count,line_count,true,{});
    return NOT;
}

\( {
    yylval.symbol = new SymbolInfo(yytext, "LPAREN", "LPAREN",line_count,line_count,true,{});
    return LPAREN;}
\) {
    yylval.symbol = new SymbolInfo(yytext, "RPAREN", "RPAREN",line_count,line_count,true,{});
    return RPAREN;}
\{ {
    yylval.symbol = new SymbolInfo(yytext, "LCURL", "LCURL",line_count,line_count,true,{});
    return LCURL;
}
\} {
    yylval.symbol = new SymbolInfo(yytext, "RCURL", "RCURL",line_count,line_count,true,{});
    return RCURL;
}
\[ {
    yylval.symbol = new SymbolInfo(yytext, "LSQUARE", "LSQUARE",line_count,line_count,true,{});
    return LSQUARE;}
\] {
    yylval.symbol = new SymbolInfo(yytext, "RSQUARE", "RSQUARE",line_count,line_count,true,{});
    return RSQUARE;}
\, {
    yylval.symbol = new SymbolInfo(yytext, "COMMA", "COMMA",line_count,line_count,true,{});
    return COMMA;}
\; {yylval.symbol = new SymbolInfo(yytext, "SEMICOLON", "SEMICOLON",line_count,line_count,true,{});
    return SEMICOLON;}

{IDENTIFIER} {
    yylval.symbol = new SymbolInfo(yytext, "ID", "ID",line_count,line_count,true,{});
    return ID;
}

\" {
    currString = yytext;
    stringStart = line_count; 
    BEGIN STRING;
}

<STRING>\\{NEWLINE} {
    currString += yytext;
    line_count++;
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
    //addString(currString, "STRING");
    BEGIN INITIAL;
    yylval.symbol = new SymbolInfo(currString, "STRING", "STRING",stringStart,line_count,true,{}); //TODO: add line number
    return STRING;
}
<STRING>{NEWLINE} {
    //error(stringStart,currString, "UNTERMINATED STRING");
    line_count++;
    error("UNTERMINATED STRING");
    BEGIN INITIAL;
    yylval.symbol = new SymbolInfo(currString, "STRING", "STRING",stringStart,line_count,true,{});
    return STRING;
}
<MULTISTRING>\\{NEWLINE} {
    currString += yytext;
    line_count++;
}
<MULTISTRING>\\\" {
    currString += yytext;
} 
<MULTISTRING>[^\"\n\r] {
    currString += yytext;
}
<MULTISTRING>\" {
    currString += yytext;
    //addString(currString, "MULTI-LINE-STRING");
    BEGIN INITIAL;
    yylval.symbol = new SymbolInfo(currString, "MULTI-LINE-STRING", "",stringStart,line_count,true,{});
    return STRING;
}
<MULTISTRING>{NEWLINE} {
    //error(stringStart,currString, "UNTERMINATED MULTI-LINE-STRING");
    error("UNTERMINATED MULTI-LINE-STRING");
    line_count++;
    BEGIN INITIAL;
}

"//" {
    currString = yytext;
    stringStart = line_count;
    BEGIN COMMENT;
}


"/*" {
    currString = yytext;
    stringStart = line_count; // save the line number of the start of the string
    BEGIN MULTI_COMMENT;
}


{TOO_MANY_DEMICAL_POINTS} {
    //error(line_count,yytext, "Redundant decimal points");
    error("Redundant decimal points");
}
{ILL_FORMAT_NUMBER} {
    //error(line_count,yytext, "Ill formatted number");
    error("Ill formatted number");
}

{INVALID_SUFFIX_OR_PREFIX} {
    //error(line_count, yytext, "Invalid prefix or suffix");
    error("Invalid prefix or suffix");
}
{MULTI_CHAR_CONST} {
    //error(line_count, yytext, "Multi character constant error");
    error("Multi character constant error");
}

\'\' {
    //error(line_count, yytext, "Empty character constant error");
    error("Empty character constant error");
}

{UNTERMINATED_CHAR} {
    //error(line_count, yytext, "Unterminated character");
    error("Unterminated character");
}


. {
    //error(line_count, yytext, "Unrecognized character");
    error("Unrecognized character");
}
%%