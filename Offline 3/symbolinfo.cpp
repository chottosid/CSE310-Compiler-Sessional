#include "bits/stdc++.h"
using namespace std;
extern ofstream logfile;
class SymbolInfo
{
private:
    string name, type;
    SymbolInfo *next;
    string type_specifier;
    bool token;
    bool array;
    bool terminal;
    int fnc_status; // 0 for no func,1 for definition,2 for declaration
    int lineStart;
    int lineEnd;
    vector<SymbolInfo *> parameters;
    vector<SymbolInfo *> declarations;
    vector<SymbolInfo *> children; // children in other code
    // function names
    // setName,setType,setNext,setTypeSpecifier,setToken,setArray,setTerminal
    // setFncStatus,setLineStart,setLineEnd,setParameters,setChildren,setDeclarations
    // addParameter,addChildren,addDeclaration
    // getName,getType,getNext,getTypeSpecifier,getToken,getArray,getTerminal
    // getFncStatus,getLineStart,getLineEnd,getParameters,getChildrens,getDeclarations
    // friend ostream &operator<<(ostream &os, const SymbolInfo &symbol)
public:
    // Remove the line: bool visited = false;
    SymbolInfo(string name, string type)
    {
        // cout << "constructor1 called\n";
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->type_specifier = "";
        this->token = false;
        this->array = false;
        this->terminal = false;
        this->fnc_status = -1;
        this->lineStart = 0;
        this->lineEnd = 0;
    }
    SymbolInfo()
    {
        // cout << "constructor2 called\n";
        this->name = "";
        this->type = "";
        this->next = nullptr;
        this->type_specifier = "";
        this->token = false;
        this->array = false;
        this->terminal = false;
        this->fnc_status = -1;
        this->lineStart = 0;
        this->lineEnd = 0;
    }
    SymbolInfo(string name, string type, string type_specifier, int linestar, int lineend, bool istoken, vector<SymbolInfo *> si)
    {
        // cout << "constructor3 called\n";
        this->name = name;
        this->type = type;
        this->type_specifier = type_specifier;
        this->lineStart = linestar;
        this->lineEnd = lineend;
        this->token = istoken;
        array = false;
        this->next = nullptr;
        for (int i = 0; i < si.size(); i++)
        {
            this->children.push_back(si[i]);
        }
        if (token and type != "")
        {
            logfile << "Line# " << lineStart << ": Token <" << type << "> Lexeme " << name << " found\n";
        }
        else if (!token and type != "")
        {
            logfile << type << "\t: " << name << "\n";
        }
        this->fnc_status = -1;
        // log2file << this->getName() << ": ";
        // for (auto x : children)
        // {
        //     log2file << x->name << " ";
        // }
        // log2file << endl;
    }
    SymbolInfo(const SymbolInfo &symbol)
    {
        cout << "constructor4 called\n";
        this->name = symbol.name;
        this->type = symbol.type;
        this->next = symbol.next;
        this->type_specifier = symbol.type_specifier;
        this->token = symbol.token;
        this->array = symbol.array;
        this->terminal = symbol.terminal;
        this->fnc_status = symbol.fnc_status;
        this->lineStart = symbol.lineStart;
        this->lineEnd = symbol.lineEnd;
        this->parameters = symbol.parameters;
        this->children = symbol.children;
        this->declarations = symbol.declarations;
    }
    void setName(string name)
    {
        this->name = name;
    }
    void setType(string type)
    {
        this->type = type;
    }
    void setNext(SymbolInfo *next)
    {
        this->next = next;
    }
    void setTypeSpecifier(string type_specifier)
    {
        this->type_specifier = type_specifier;
    }
    void setToken(bool token)
    {
        this->token = token;
    }
    void setArray(bool array)
    {
        this->array = array;
    }
    void setTerminal(bool terminal)
    {
        this->terminal = terminal;
    }
    void setFncStatus(int fnc_status)
    {
        this->fnc_status = fnc_status;
    }
    void setLineStart(int lineStart)
    {
        this->lineStart = lineStart;
    }
    void setLineEnd(int lineEnd)
    {
        this->lineEnd = lineEnd;
    }
    void setParameters(vector<SymbolInfo *> parameters)
    {
        this->parameters = parameters;
    }
    void setChildren(vector<SymbolInfo *> children)
    {
        this->children = children;
    }
    void setDeclarations(vector<SymbolInfo *> declarations)
    {
        this->declarations = declarations;
    }
    void addParameter(SymbolInfo *parameter)
    {
        this->parameters.push_back(parameter);
    }
    void addChildren(SymbolInfo *child)
    {
        this->children.push_back(child);
    }
    void addDeclaration(SymbolInfo *declaration)
    {
        this->declarations.push_back(declaration);
    }
    string getName()
    {
        return this->name;
    }
    string getType()
    {
        return this->type;
    }
    SymbolInfo *getNext()
    {
        if (next == nullptr)
            return nullptr;
        return this->next;
    }
    string getTypeSpecifier()
    {
        return this->type_specifier;
    }
    bool getToken()
    {
        return this->token;
    }
    bool getArray()
    {
        return this->array;
    }
    bool getTerminal()
    {
        return this->terminal;
    }
    int getFncStatus()
    {
        return this->fnc_status;
    }
    int getLineStart()
    {
        return this->lineStart;
    }
    int getLineEnd()
    {
        return this->lineEnd;
    }
    vector<SymbolInfo *> getParameters()
    {
        return this->parameters;
    }
    vector<SymbolInfo *> getChildren()
    {
        return this->children;
    }
    vector<SymbolInfo *> getDeclarations()
    {
        return this->declarations;
    }
    void printTree(int offset, ostream &parsetree)
    {
        if (name == "error" or name == "ERROR")
            return;
        for (int i = 0; i < offset; i++)
        {
            parsetree << " ";
        }
        if (token)
            parsetree << type << " : " << name << " \t<Line: " << lineStart << ">\n";
        else
            parsetree << type << " :" << name << " \t<Line: " << lineStart << "-" << lineEnd << ">\n";
        for (auto s : children)
        {
            s->printTree(offset + 1, parsetree);
        }
    }
    // void printTree(int offset1, ostream &parsetree)
    // {
    //     queue<SymbolInfo *> q;
    //     q.push(this);
    //     int cnt = 0;
    //     while (!q.empty() and cnt < 100)
    //     {
    //         auto x = q.front();
    //         q.pop();
    //         x->print();
    //         for (auto y : x->children)
    //         {
    //             q.push(y);
    //         }
    //         cnt++;
    //     }
    // }
    // void print()
    // {
    //     cout << name << " 's children are : ";
    //     for (auto x : children)
    //     {
    //         cout << x->name << " ";
    //     }
    //     cout << endl;
    // }
    string getStatement()
    {
        if (token)
            return name;
        string a = "";
        for (auto b : children)
        {
            a += b->getStatement();
        }
        return a;
    }
    friend ostream &operator<<(ostream &os, const SymbolInfo &symbol)
    {
        os << "\t( " << symbol.name << " : " << symbol.type << " )";
        return os;
    }
};