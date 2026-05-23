#pragma once
#include <iostream>
#include <string>
#include "scopetable.h"
using namespace std;

class SymbolTable
{
private:
    ScopeTable *currentScope;
    int tableSize;
    int tableCount;

public:
    // static int tableCount;
    SymbolTable(int tableSize)
    {
        this->tableSize = tableSize;
        currentScope = new ScopeTable(tableSize, NULL);
        tableCount = 1;
    };
    ~SymbolTable()
    {
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            ScopeTable *temp2 = temp;
            temp = temp->getParentScope();
            temp2->~ScopeTable();
            delete temp2;
        }
    };
    void enterScope()
    {
        ScopeTable *newScope = new ScopeTable(tableSize, currentScope);
        currentScope = newScope;
        tableCount++;
    };
    void exitScope()
    {
        ScopeTable *temp = currentScope;
        currentScope = currentScope->getParentScope();
        delete temp;
        tableCount--;
    };
    bool insert(string name, string type)
    {
        return currentScope->insert(name, type);
    };
    bool remove(string name)
    {
        return currentScope->deleteSymbol(name);
    };
    SymbolInfo *lookUp(string name)
    {
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            SymbolInfo *symbol = temp->lookup(name);
            if (symbol != NULL)
            {
                return symbol;
            }
            temp = temp->getParentScope();
        }
        return NULL;
    };
    ScopeTable *lookupScope(string name)
    {
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            SymbolInfo *symbol = temp->lookup(name);
            if (symbol != NULL)
            {
                return temp;
            }
            temp = temp->getParentScope();
        }
        return NULL;
    };
    void printCurrentScope()
    {
        currentScope->print();
    };
    void printAllScope()
    {
        ScopeTable *temp = currentScope;
        while (temp != NULL)
        {
            temp->print();
            temp = temp->getParentScope();
        }
    };
    ScopeTable *getCurrentScope()
    {
        return currentScope;
    };
    void exitAllScope()
    {
        while (currentScope != NULL)
        {
            exitScope();
        }
    }
    int getTableCount()
    {
        return tableCount;
    }
};