%{
#include<bits/stdc++.h>
#include "symboltable.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;

SymbolTable* symboltable;
SymbolInfo *current_params=new SymbolInfo("","","",0,0,false,{}); //for parameter list

SymbolInfo *start_node;//for printing parse tree
extern int error_count;//for counting errors
extern int line_count;//for counting lines

ofstream errorfile;
ofstream logfile;
ofstream parsetreefile;

void yyerror(char *s)
{
	//printf("Error: %s\n",s);
}
int yylex(void);
void log(string name,string type){
    logfile<<name<<" : "<<type<<endl;
}
void error(string s){
    errorfile<<"Line# "<<line_count<<" : "<<s<<endl;
    error_count++;
}

string symbol_caste_help(SymbolInfo* a,SymbolInfo* b){      //for type casting float and int
	if(a->getTypeSpecifier() == "error" or b->getTypeSpecifier() == "error" or a->getTypeSpecifier() == "VOID"  or b->getTypeSpecifier() == "VOID"  ) return "error"; 
	else if(a->getTypeSpecifier() == "FLOAT" or b->getTypeSpecifier() == "FLOAT" ) return "FLOAT";
	else return "INT";
}
string getRule(const vector<SymbolInfo*> s) {
    string str = "";
    for (auto type : s) {
        str += " ";
        str += type->getType();
    }
    return str;
}

void checkfunc(SymbolInfo* name_f, SymbolInfo* type_f){         //check if function already defined
	name_f->setTypeSpecifier(type_f->getTypeSpecifier());
	name_f->setParameters(current_params->getParameters());
	name_f->setFncStatus(2);
	
	SymbolInfo* old = symboltable->lookUp(name_f->getName());
    if(old==nullptr){
        symboltable->insert(name_f);
        return;
    }
	else if( old->getFncStatus()==0 ){
		error("\'"+name_f->getName()+"\' redeclared as different kind of symbol");
	}
    else if(old->getFncStatus()==1){
        if(old->getTypeSpecifier()!=name_f->getTypeSpecifier()){
            error("Conflicting types for \'"+name_f->getName()+"\'");
        }
        if(old->getParameters().size()!=name_f->getParameters().size()){
            error("Conflicting types for \'"+name_f->getName()+"\'");
        }
        else{
            vector<SymbolInfo*> declaredArgs = old->getParameters();
            vector<SymbolInfo*> definedArgs = name_f->getParameters();
            for(int i=0;i<declaredArgs.size();i++){
                if(declaredArgs[i]->getTypeSpecifier()!=definedArgs[i]->getTypeSpecifier()){
                    error("Type mismatch for argument "+to_string(i+1)+" of '"+name_f->getName()+"'");
                }
            }
        }
    }
    else if(old->getFncStatus()==2){
		error("Function already declared");
	}
	
}

%}

%union
{
    SymbolInfo *symbol;
}
%token<symbol> CONST_FLOAT CONST_INT IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP BITOP NOT LPAREN RPAREN LSQUARE RSQUARE LCURL RCURL COMMA SEMICOLON ID DECOP STRING CONST_CHAR
%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments lcurl error

%nonassoc THEN
%nonassoc ELSE
/* %nonassoc LOWER_THAN_ELSE
%nonassoc ELSE */

%%

start : program
        {
            $$=new SymbolInfo(getRule({$1}),"start","",$1->getLineStart(),$1->getLineEnd(),false,{$1});
            start_node=$$;      //iniital node stored in start_node
            logfile<<"Total Lines: "<<line_count<<endl;
            logfile<<"Total Errors: "<<error_count<<endl;
        }
;

program : program unit
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"program","",$1->getLineStart(),$2->getLineEnd(),false,{$1,$2});
        }
	| unit
        {
            $$ = new SymbolInfo(getRule({$1}),"program","",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
;
	
unit : var_declaration
        {
            $$ = new SymbolInfo(getRule({$1}),"unit","",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
    | func_declaration
        {
            $$ = new SymbolInfo(getRule({$1}),"unit","",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
    | func_definition
        {
            $$ = new SymbolInfo(getRule({$1}),"unit","",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
    /* | error
        {
            yyclearin; yyerrok; error("Syntax error at unit");
            $$ = new SymbolInfo("error","unit","",$1->getLineStart(),$1->getLineEnd(),true,{$1});
        } */
;
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$6}),"func_declaration","",$1->getLineStart(),$5->getLineEnd(),false,{$1,$2,$3,$4,$5,$6});
            $2->setTypeSpecifier($1->getTypeSpecifier());
            $2->setFncStatus(1); //state as function
            $2->setParameters($4->getParameters());
            current_params->setParameters({});
            if(symboltable->lookUp($2->getName())!=nullptr) error("Function already declared");
            else{ symboltable->insert($2);}
        }
    /* | type_specifier ID LPAREN error RPAREN SEMICOLON
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$6}),"func_declaration","",$1->getLineStart(),$6->getLineEnd(),false, {$1,$2,$3,$4,$5,$6}); 
            $2->setTypeSpecifier($1->getTypeSpecifier()); 
            $2->setFncStatus(1);
            current_params->setParameters({});
            symboltable->insert($2);
        }				 */
    | type_specifier ID LPAREN RPAREN SEMICOLON
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5}),"func_declaration","",$1->getLineStart(),$5->getLineEnd(),false, {$1,$2,$3,$4,$5});
            $2->setTypeSpecifier($1->getTypeSpecifier());
            $2->setFncStatus(1);
            $2->setParameters({});
            if(symboltable->lookUp($2->getName())!=nullptr) error("Function already declared");
            else symboltable->insert($2);
        }
;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {checkfunc($2,$1);} compound_statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$7}),"func_definition","",$1->getLineStart(),$7->getLineEnd(),false,{$1,$2,$3,$4,$5,$7});
        }
    |   type_specifier ID LPAREN error RPAREN {checkfunc($2,$1);} compound_statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$7}),"func_definition","",$1->getLineStart(),$7->getLineEnd(),false, {$1,$2,$3,$4,$5,$7}); 
            error("Syntax error at parameter list of function definition");
        }   //mushfiq did this
    | type_specifier ID LPAREN RPAREN {checkfunc($2,$1);} compound_statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$6}),"func_definition","",$1->getLineStart(),$6->getLineEnd(),false,{$1,$2,$3,$4,$6});
        }
;				

parameter_list : parameter_list COMMA type_specifier ID							
        { 
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"parameter_list","",$1->getLineStart(),$4->getLineEnd(),false, {$1,$2,$3,$4}); 
            $$->setParameters($1->getParameters()); 
            $$->addParameter($4); 
            $4->setTypeSpecifier($3->getTypeSpecifier()); 
            current_params->setParameters($$->getParameters()); 
            if($4->getTypeSpecifier()=="VOID" or $4->getTypeSpecifier()=="") error("Variable or field '"+ $4->getName()+"' declared void"); 
        }
	| parameter_list COMMA type_specifier
        { 
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"parameter_list","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); 
            SymbolInfo* x = new SymbolInfo("","ID","",line_count,line_count,false,{});
            $$->setParameters($1->getParameters()); 
            $$->addParameter(x);  
            x->setTypeSpecifier($3->getTypeSpecifier()); 
            current_params->setParameters($$->getParameters()); 
            if(x->getTypeSpecifier()=="VOID" or x->getTypeSpecifier()=="") error("Variable or field '"+ x->getName()+"' declared void");
        }
	| type_specifier ID
        { 
            $$ = new SymbolInfo(getRule({$1,$2}),"parameter_list","",$1->getLineStart(),$2->getLineEnd(),false,{$1,$2}); 
            $2->setTypeSpecifier($1->getTypeSpecifier()); 
            $$->addParameter($2); 
            current_params->setParameters($$->getParameters()); 
            if($2->getTypeSpecifier()=="VOID" or $2->getTypeSpecifier()=="") error("Variable or field '"+ $2->getName()+"' declared void");
        }
	| type_specifier
        {
            $$ = new SymbolInfo(getRule({$1}),"parameter_list","",$1->getLineStart(),$1->getLineEnd(),false,{$1}); 
            SymbolInfo* x = new SymbolInfo("","ID","",line_count,line_count,false,{}); 
            x->setTypeSpecifier($1->getTypeSpecifier()); 
            $$->addParameter(x); 
            current_params->setParameters($$->getParameters()); 
            if(x->getTypeSpecifier()=="VOID" or x->getTypeSpecifier()=="") error("Variable or field '"+ x->getName()+"' declared void");
        }
	/* | error
        {
            yyclearin;
            yyerrok;
            error("Syntax error at parameter list of function definition"); 
			$$ = new SymbolInfo("error","parameter_list","",line_count,line_count,true,{$1});
        } */
;
compound_statement : lcurl statements RCURL
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"compound_statement","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
            symboltable->printAllScope(logfile); symboltable->exitScope();
        }
	/* | lcurl error RCURL					
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"compound_statement","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); symboltable->printAllScope(logfile); symboltable->exitScope();
        } */
	| lcurl RCURL						
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"compound_statement","",$1->getLineStart(),$2->getLineEnd(),false, {$1,$2}); symboltable->printAllScope(logfile); symboltable->exitScope();
        }
;
var_declaration	: type_specifier declaration_list SEMICOLON							
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"var_declaration","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
            for(auto x : $2->getDeclarations()){ 
                x->setTypeSpecifier($1->getTypeSpecifier()); 
                x->setFncStatus(0);
                if(x->getTypeSpecifier()=="VOID") error("Variable or field '"+ x->getName()+"' declared void");
                else if(!symboltable->insert(x)) error("Conflicting types for \'"+x->getName()+"\'");	
            }  
        }
	| type_specifier error SEMICOLON 	
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"var_declaration","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
														    error("Syntax error at declaration list of variable declaration");
        } //mushfiq did this
    | type_specifier declaration_list error SEMICOLON
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"var_declaration","",$1->getLineStart(),$4->getLineEnd(),false, {$1,$2,$3,$4});
            for(auto x:$2->getDeclarations()){
                x->setTypeSpecifier($1->getTypeSpecifier());
                x->setFncStatus(0);
                if(x->getTypeSpecifier()=="VOID") error("Variable or field '"+ x->getName()+"' declared void");
                else if(!symboltable->insert(x)) error("Conflicting types for \'"+x->getName()+"\'");
            }
            error("Syntax error at declaration list of variable declaration");
        
        } //mushfiq did this
    
;
type_specifier : INT								
        {
            $$ = new SymbolInfo(getRule({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| FLOAT								
        {
            $$ = new SymbolInfo(getRule({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| VOID								
        {
            $$ = new SymbolInfo(getRule({$1}),"type_specifier",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
;
declaration_list : declaration_list COMMA ID
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"declaration_list","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); 
			$$->setDeclarations($1->getDeclarations()); 
            $$->addDeclaration($3);  
            $3->setArray(false); 
            SymbolInfo* a = symboltable->lookUp($3->getName());
            if(a!=nullptr and a->getFncStatus()!=0) error("Function exists");
        }
	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$6}),"declaration_list","",$1->getLineStart(),$6->getLineEnd(),false, {$1,$2,$3,$4,$5,$6}); 
            $$->setDeclarations($1->getDeclarations()); 
            $$->addDeclaration($3); 
            $3->setArray(true);  
            SymbolInfo* a = symboltable->lookUp($3->getName());
            if(a!=nullptr and a->getFncStatus()!=0) error("Function exists");
        }
	| ID
        { 
            $$ = new SymbolInfo(getRule({$1}),"declaration_list","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
            $$->addDeclaration($1);  
            $1->setArray(false); 
            SymbolInfo* x = symboltable->lookUp($1->getName());
            if(x!=nullptr and x->getFncStatus()!=0) 
            error("Function exists");
        }

	| ID LSQUARE CONST_INT RSQUARE
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"declaration_list","",$1->getLineStart(),$4->getLineEnd(),false, {$1,$2,$3,$4}); 
            $$->addDeclaration($1);  
            $1->setArray(true);  
            SymbolInfo* a = symboltable->lookUp($1->getName());
            if(a!=nullptr && a->getFncStatus()!=0) 
            error("Function exists");
        }
    /* | error
        {
            yyclearin; yyerrok;
            error("Syntax error at declaration list of variable declaration"); 
			$$ = new SymbolInfo("error","declaration_list","",line_count,line_count,true, {$1});
        } */
;
statements : statement
        {
            $$ = new SymbolInfo(getRule({$1}),"statements","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| statements statement
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"statements","",$1->getLineStart(),$2->getLineEnd(),false, {$1,$2});
        }
;
statement : var_declaration
        {
            $$ = new SymbolInfo(getRule({$1}),"statement","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| expression_statement
        {
            $$ = new SymbolInfo(getRule({$1}),"statement","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| compound_statement
        {
            $$ = new SymbolInfo(getRule({$1}),"statement","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$6,$7}),"statement","",$1->getLineStart(),$7->getLineEnd(),false, {$1,$2,$3,$4,$5,$6,$7});
        }
	| IF LPAREN expression RPAREN statement %prec THEN								
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5}),"statement","",$1->getLineStart(),$5->getLineEnd(),false, {$1,$2,$3,$4,$5});
        }
	| IF LPAREN expression RPAREN statement ELSE statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5,$6,$7}),"statement","",$1->getLineStart(),$7->getLineEnd(),false, {$1,$2,$3,$4,$5,$6,$7});
        }
	| WHILE LPAREN expression RPAREN statement
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5}),"statement","",$1->getLineStart(),$5->getLineEnd(),false, {$1,$2,$3,$4,$5});
        }
	| PRINTLN LPAREN ID RPAREN SEMICOLON								
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4,$5}),"statement","",$1->getLineStart(),$5->getLineEnd(),false, {$1,$2,$3,$4,$5});
			if( symboltable->lookUp($3->getName())!=nullptr )
                error("Undeclared variable '"+$3->getName()+"'"); 
        }
    | RETURN expression SEMICOLON
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"statement","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
        }
;
expression_statement: SEMICOLON							
        { 
            $$ = new SymbolInfo(getRule({$1}),"expression_statement","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
        }
	| expression SEMICOLON
    {
        $$ = new SymbolInfo(getRule({$1,$2}),"expression_statement",$1->getTypeSpecifier(),$1->getLineStart(),$2->getLineEnd(),false, {$1,$2});
    }
	| error SEMICOLON  
        {
            yyclearin; yyerrok;
            error("Syntax error at expression of expression statement"); 
			$$ = new SymbolInfo("error","expression_statement","",line_count,line_count,true, {});
        }//mushfiq did this }
;
variable : ID
        {
            $$ = new SymbolInfo(getRule({$1}),"variable","",$1->getLineStart(),$1->getLineEnd(),false, {$1});
			SymbolInfo* a = symboltable->lookUp($1->getName());
        
            if( a==nullptr){
                error("Undeclared variable '"+$1->getName()+"'");
                $$->setTypeSpecifier("error");
            }
            else {
                $$->setTypeSpecifier(a->getTypeSpecifier()); $$->setArray(a->getArray());
                } 
        }
	| ID LSQUARE expression RSQUARE
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"variable","",$1->getLineStart(),$4->getLineEnd(),false, {$1,$2,$3,$4});
            SymbolInfo* a = symboltable->lookUp($1->getName());
            if( a==nullptr  or (a!=nullptr and a->getFncStatus()!=0)){
                error("Undeclared variable '"+$1->getName()+"'");
                $$->setTypeSpecifier("error");
            }
            else if(!a->getArray()){ error("'"+$1->getName()+"' is not an array"); $$->setTypeSpecifier("error"); }
            else if($3->getTypeSpecifier()!="INT"){
                error("Array subscript is not an integer");
                $$->setTypeSpecifier("error");
            }
            else { $$->setTypeSpecifier(a->getTypeSpecifier()); $$->setArray(false); }
        }
/* | ID LSQUARE error RSQUARE
        { $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"variable","",$1->getLineStart(),$4->getLineEnd(),false, {$1,$2,$3,$4});
        error("No index in array."); } */
;
expression : logic_expression
        {
            $$ = new SymbolInfo(getRule({$1}),"expression",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1}); $$->setArray($1->getArray());
        }
	| variable ASSIGNOP logic_expression
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"expression","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
            $$->setArray($1->getArray());
            if(($3->getArray() && !$1->getArray()) || ($1->getArray() && !$3->getArray())){
                error("Array type mismatch."); $$->setArray(false); }
            else if($3->getTypeSpecifier()=="VOID"){
                    
            }
            else if($1->getTypeSpecifier() == "INT" && $3->getTypeSpecifier()=="FLOAT"){
                error("Warning: possible loss of data in assignment of FLOAT to INT");
            }
        }
/* | error
    { yyclearin; yyerrok;
    $$ = new SymbolInfo("error","expression","",line_count,line_count,true, {$1}); } */
;
logic_expression : rel_expression					
        {
            $$ = new SymbolInfo(getRule({$1}),"logic_expression",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});  
            $$->setArray($1->getArray());
        }
	| rel_expression LOGICOP rel_expression								
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"logic_expression","INT",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); 
            if( $1->getArray() || $3->getArray() ){
                error("Cant't declare as array. ");
            }else if( $3->getTypeSpecifier() == "VOID" || $1->getTypeSpecifier() == "VOID"){
                error("Void cannot be used in expression "); $$->setTypeSpecifier("error");

            }else if( !($1->getTypeSpecifier()== "INT" and $3->getTypeSpecifier() == "INT") ){
                error("Type mismatch");
            }
        }
;
rel_expression	: simple_expression					
        {
            $$ = new SymbolInfo(getRule({$1}),"rel_expression",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});   $$->setArray($1->getArray());
        }
	| simple_expression RELOP simple_expression							
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"rel_expression","INT",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); 
            if( $1->getArray() or $3->getArray() ){
                error("Array Not Allowed");
            }
            else if( $3->getTypeSpecifier() == "VOID" || $1->getTypeSpecifier() == "VOID"){
                error("Void cannot be used in expression "); $$->setTypeSpecifier("error");
            }
        }
;
simple_expression : term 
        {
            $$ = new SymbolInfo(getRule({$1}),"simple_expression",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});    $$->setArray($1->getArray());
        }
	| simple_expression ADDOP term		
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"simple_expression",symbol_caste_help($1,$3),$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
            if( $3->getArray() ){
                error("Cant't declare as array. ");
            }else if( $3->getTypeSpecifier() == "VOID"){
                error("Void cannot be used in expression "); $$->setTypeSpecifier("error");
            }
        }
;
term : unary_expression
        {
            $$ = new SymbolInfo(getRule({$1}),"term",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1});
			$$->setArray($1->getArray());
        }
	| term MULOP unary_expression
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"term",symbol_caste_help($1,$3),$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
            if( $3->getArray() ) error("Cant't declare as array. ");
            else if( $3->getTypeSpecifier() == "VOID"){
                error("Void cannot be used in expression "); $$->setTypeSpecifier("error");
            }
            else if( $2->getName() == "%" && $3->getStatement() == "0" ){ error("Warning: division by zero i=0f=1Const=0"); $$->setTypeSpecifier("error"); }
            else if($2->getName() == "%" && ( $1->getTypeSpecifier() != "INT" || $3->getTypeSpecifier() != "INT") ){ error("Operands of modulus must be integers "); $$->setTypeSpecifier("error"); } 
            else if( $2->getName() == "/" and $3->getStatement() == "0" ){ error("Warning: division by zero i=0f=1Const=0"); $$->setTypeSpecifier("error"); }
        }
;
unary_expression : ADDOP unary_expression
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"unary_expression",$2->getTypeSpecifier(),$1->getLineStart(),$2->getLineEnd(),false, {$1,$2}); 
            if( $2->getArray()){ error("Cant't declare as array. "); }
            if( $1->getTypeSpecifier() == "VOID" ){
                error("Void cannot be used in expression "); $$->setTypeSpecifier("error");
            } 
        }
	| NOT unary_expression
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"unary_expression","INT",$1->getLineStart(),$2->getLineEnd(),false, {$1,$2}); 
            if( $2->getArray() ) error("Cant't declare as array. ");
            if( $1->getTypeSpecifier() != "INT" ){ error("Must be of integer type");  $$->setTypeSpecifier("error"); }
        }
	| factor
        {
            $$ = new SymbolInfo(getRule({$1}),"unary_expression",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false, {$1}); $$->setArray($1->getArray());
        }
;
factor : variable
        {
            $$ = new SymbolInfo(getRule({$1}),"factor",$1->getTypeSpecifier(),$1->getLineStart(),$1->getLineEnd(),false,{$1});
            $$->setArray($1->getArray());
        }
	| ID LPAREN argument_list RPAREN
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3,$4}),"factor","error",$1->getLineStart(),$4->getLineEnd(),false,{$1,$2,$3,$4}); 
            SymbolInfo* a = symboltable->lookUp($1->getName());
            if(a==nullptr) error("Undeclared function '"+$1->getName()+"'");
            else if(a->getFncStatus()==0) error($1->getName()+" is not a function");
            else{
                $$->setTypeSpecifier(a->getTypeSpecifier());
                if( $3->getParameters().size() !=  a->getParameters().size()) error("Undeclared function '"+$1->getName()+"'");
                else if($3->getParameters().size() >  a->getParameters().size()) error("Undeclared function '"+$1->getName()+"'");
                else{
                    vector<SymbolInfo*> b = $3->getParameters();
                    vector<SymbolInfo*> c = a->getParameters();
                    for(int i=0;i<b.size();i++){
                        if( b[i]->getTypeSpecifier()!= c[i]->getTypeSpecifier()) error("Type mismatch for argument "+to_string(i+1)+" of '"+$1->getName()+"'");
                        else if( b[i]->getArray() and !c[i]->getArray() ) error("'"+b[i]->getName()+"' is an array");
                        else if( !b[i]->getArray() and c[i]->getArray() ) error("'"+b[i]->getName()+"' is not an array");
                    }
                }
            }   
        }
	| LPAREN expression RPAREN
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"factor",$1->getTypeSpecifier(),$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3});
        }
	| CONST_INT	
        {
            $$ = new SymbolInfo(getRule({$1}),"factor","INT",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
	| CONST_FLOAT
        {
            $$ = new SymbolInfo(getRule({$1}),"factor","FLOAT",$1->getLineStart(),$1->getLineEnd(),false,{$1});
        }
	| variable INCOP
        {
            $$ = new SymbolInfo(getRule({$1,$2}),"factor",$1->getTypeSpecifier(),$1->getLineStart(),$2->getLineEnd(),false,{$1,$2}); 
            if( $1->getTypeSpecifier() == "VOID" ){ error("Variable or field '"+$1->getName()+"' declared void");  $$->setTypeSpecifier("error"); /* Do I need it? */ } 
        }
;
argument_list : arguments							
        {
            $$ = new SymbolInfo(getRule({$1}),"argument_list","",$1->getLineStart(),$1->getLineEnd(),false,{$1}); 
            $$->setParameters($1->getParameters());
        }			
	/* | arguments error
        {
            yyclearin; yyerrok;
            error("Syntax error at arguments");
            $$ = new SymbolInfo(getRule({$1}),"argument_list","",$1->getLineStart(),$2->getLineEnd(),false,{$1}); 
            $$->setParameters($1->getParameters());
        } */
	|
        {
            $$ = new SymbolInfo(getRule({}),"argument_list","",line_count,line_count,false,{});
        }
;
arguments : arguments COMMA logic_expression
        {
            $$ = new SymbolInfo(getRule({$1,$2,$3}),"arguments","",$1->getLineStart(),$3->getLineEnd(),false, {$1,$2,$3}); 
            $$->setParameters($1->getParameters()); 
            $$->addParameter($3);
        }
	| logic_expression
        {
            $$ = new SymbolInfo(getRule({$1}),"arguments","",$1->getLineStart(),$1->getLineEnd(),false,{$1}); 
            $$->addParameter($1);
        }
;
lcurl : LCURL								
    { 
        $$ = $1;
        symboltable->enterScope();
        for(auto a : current_params->getParameters()){
            if( a->getName() == "" ) continue;
            if( a->getTypeSpecifier() == "VOID" ) a->setTypeSpecifier("error");  // do I need it?
            if(!symboltable->insert(a)) error("Redefinition of parameter \'"+a->getName()+"\'"); // ulta hobe na?
        }
        current_params->setParameters({});
    }	
;
%%
int main(int argc, char *argv[]) {
    if (argc != 2) {
        cout << "Usage: " << argv[0] << " input_file" << endl;
        return 1;
    }

    FILE *fin = freopen(argv[1], "r", stdin);
    if (fin == nullptr) {
        cout << "Error: Unable to open input file " << argv[1] << endl;
        return 1;
    }
    string filename=argv[1];
    symboltable = new SymbolTable(11);

    errorfile.open("error.txt");
    logfile.open("log.txt");
    parsetreefile.open("parsetree.txt");

    if (!errorfile.is_open() || !logfile.is_open() || !parsetreefile.is_open()) {
        cout << "Error: Unable to open output files" << endl;
        return 1;
    }
    yyin = fin;
    yylineno = 1;

    if (yyparse() == 0) {
        cout << "Parsing completed successfully." << endl;
    } else {
        cout << "Parsing encountered errors." << endl;
    }

    fclose(fin);
    start_node->printTree(0,parsetreefile);
    errorfile.close();
    logfile.close();
    parsetreefile.close();

    return 0;
}
