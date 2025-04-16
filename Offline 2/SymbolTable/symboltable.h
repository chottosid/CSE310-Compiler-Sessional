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
        currentScope = new ScopeTable(tableSize, nullptr);
        tableCount = 1;
    };
    ~SymbolTable()
    {
        ScopeTable *temp = currentScope;
        while (temp != nullptr)
        {
            ScopeTable *temp2 = temp;
            temp = temp->getParentScope();
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
        while (temp != nullptr)
        {
            SymbolInfo *symbol = temp->lookup(name);
            if (symbol != nullptr)
            {
                return symbol;
            }
            temp = temp->getParentScope();
        }
        return nullptr;
    };
    ScopeTable *lookupScope(string name)
    {
        ScopeTable *temp = currentScope;
        while (temp != nullptr)
        {
            SymbolInfo *symbol = temp->lookup(name);
            if (symbol != nullptr)
            {
                return temp;
            }
            temp = temp->getParentScope();
        }
        return nullptr;
    };
    void printCurrentScope()
    {
        currentScope->print();
    };
    void printAllScope()
    {
        ScopeTable *temp = currentScope;
        while (temp != nullptr)
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
        while (currentScope != nullptr)
        {
            exitScope();
        }
    }
    int getTableCount()
    {
        return tableCount;
    }
};