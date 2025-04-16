#include "symbolinfo.h"
typedef unsigned long long ull;
using namespace std;
class ScopeTable
{
private:
    SymbolInfo **table;
    int tableSize, childcnt;
    string scopeID;
    ScopeTable *parentScope;
    ull hashFunction(string name)
    {
        ull hash = 0;
        int c;
        for (int i = 0; i < name.length(); i++)
        {
            c = name[i];
            hash = (ull)c + (hash << 6) + (hash << 16) - hash;
        }
        hash++;
        if (hash % (ull)tableSize == 0)
            hash = (ull)tableSize;
        else
            hash = hash % (ull)tableSize;
        return hash;
    }

public:
    ScopeTable(int tableSize, ScopeTable *parentScope)
    {
        this->tableSize = tableSize;
        this->parentScope = parentScope;
        this->childcnt = 0;
        table = new SymbolInfo *[tableSize + 2];
        for (int i = 0; i < tableSize + 2; i++)
        {
            table[i] = nullptr;
        }
        if (parentScope == nullptr)
        {
            scopeID = "1";
        }
        else
        {
            scopeID = parentScope->scopeID + "." + to_string(parentScope->childcnt + 1);
            parentScope->increaseChildCnt();
        }
        cout << "\tScopeTable# " << scopeID << " created" << endl;
    }
    ~ScopeTable()
    {
        for (int i = 0; i < tableSize + 2; i++)
        {
            SymbolInfo *temp = table[i];
            while (temp != nullptr)
            {
                SymbolInfo *temp2 = temp;
                temp = temp->getNext();
                delete temp2;
            }
        }

        delete[] table;
    }

    string getScopeId()
    {
        return scopeID;
    }
    void setParentScope(ScopeTable *parentScope)
    {
        this->parentScope = parentScope;
    }
    ScopeTable *getParentScope()
    {
        return parentScope;
    }
    bool insert(string name, string type)
    {
        int hash = hashFunction(name);
        SymbolInfo *temp = table[hash];
        SymbolInfo *prev = nullptr;
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                return false;
            }
            prev = temp;
            temp = temp->getNext();
        }
        SymbolInfo *newSymbol = new SymbolInfo(name, type);
        if (prev == nullptr)
        {
            table[hash] = newSymbol;
        }
        else
        {
            prev->setNext(newSymbol);
        }
        return true;
    }

    SymbolInfo *lookup(string name)
    {
        int hash = hashFunction(name);
        SymbolInfo *temp = table[hash];
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                return temp;
            }
            temp = temp->getNext();
        }
        return nullptr;
    }
    bool deleteSymbol(string name)
    {
        int hash = hashFunction(name);
        SymbolInfo *temp = table[hash];
        SymbolInfo *prev = nullptr;
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                if (prev == nullptr)
                {
                    table[hash] = temp->getNext();
                }
                else
                {
                    prev->setNext(temp->getNext());
                }
                delete temp;
                return true;
            }
            prev = temp;
            temp = temp->getNext();
        }
        return false;
    }
    void print()
    {
        cout << "\tScopeTable# " << scopeID << endl;
        for (int i = 1; i <= tableSize; i++)
        {
            if (table[i] == nullptr)
            {
                cout << "\t" << i << endl;
                continue;
            }
            cout << "\t" << i << " --> ";
            SymbolInfo *temp = table[i];
            SymbolInfo *prev = nullptr;
            while (temp != nullptr)
            {
                if (prev != nullptr)
                {
                    cout << " --> ";
                }
                cout << "(" << temp->getName() << "," << temp->getType() << ")";
                temp = temp->getNext();
                prev = temp;
            }
            cout << endl;
        }
    }
    int getHashIndex(string name)
    {
        return hashFunction(name);
    }
    void increaseChildCnt()
    {
        childcnt++;
    }
    int probCount(string name)
    {
        int hash = hashFunction(name);
        SymbolInfo *temp = table[hash];
        int cnt = 0;
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                return cnt + 1;
            }
            temp = temp->getNext();
            cnt++;
        }
        return -1;
    }
};