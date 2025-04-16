#pragma once
#include <iostream>
#include <string>
using namespace std;

class SymbolInfo
{
private:
    string name, type;
    SymbolInfo *next;

public:
    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
    }
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    SymbolInfo *getNext()
    {
        return next;
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
    friend ostream &operator<<(ostream &os, const SymbolInfo &symbol)
    {
        os << "\t( " << symbol.name << " : " << symbol.type << " )";
        return os;
    }
};