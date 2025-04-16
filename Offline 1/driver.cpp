// Purpose: Driver for the compiler
#include <bits/stdc++.h>
#include "symboltable.h"
#include <iomanip>
using namespace std;

int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    int tableSize;
    string command;
    getline(cin, command);
    tableSize = stoi(command);
    SymbolTable *symbolTable = new SymbolTable(tableSize);
    int line = 0;
    while (getline(cin, command))
    {
        string tokens[100];
        int tokenCount = 0;
        for (int i = 0; i < command.length(); i++)
        {
            if (command[i] == ' ')
            {
                continue;
            }
            string token = "";
            while (i < command.length() && command[i] != ' ')
            {
                token += command[i];
                i++;
            }
            tokens[tokenCount++] = token;
        }
        line++;
        cout << "Cmd " << line << ": " << command << endl;
        if (tokens[0] == "I" and tokenCount == 3)
        {
            if (symbolTable->insert(tokens[1], tokens[2]))
            {
                // int pos = symbolTable->getCurrentScope()->getHashIndex(tokens[1]);
                cout << "\tInserted  at position <" << symbolTable->getCurrentScope()->getHashIndex(tokens[1]) << ", " << symbolTable->getCurrentScope()->probCount(tokens[1]) << "> of ScopeTable# " << symbolTable->getCurrentScope()->getScopeId() << endl;
            }
            else
            {
                cout << "\t'" << tokens[1] << "' already exists in the current ScopeTable# " << symbolTable->getCurrentScope()->getScopeId() << endl;
            }
        }
        else if (tokens[0] == "L" and tokenCount == 2)
        {
            SymbolInfo *symbol = symbolTable->lookUp(tokens[1]);
            if (symbol == NULL)
            {
                cout << "\t"
                     << "'" << tokens[1] << "' not found in any of the ScopeTables" << endl;
            }
            else
            {
                ScopeTable *temp = symbolTable->lookupScope(tokens[1]);
                cout << "\t'" << tokens[1] << "' found at position <" << temp->getHashIndex(tokens[1]) << ", " << temp->probCount(tokens[1]) << "> of ScopeTable# " << temp->getScopeId() << endl;
            }
        }
        else if (tokens[0] == "D" and tokenCount == 2)
        {
            if (symbolTable->remove(tokens[1]))
            {
                cout << "\tDeleted "
                     << "'" << tokens[1] << "' from position <" << symbolTable->getCurrentScope()->getHashIndex(tokens[1]) << ", " << symbolTable->getCurrentScope()->getScopeId() << "> of ScopeTable# " << symbolTable->getCurrentScope()->getScopeId() << endl;
            }
            else
            {
                cout << "\tNot found in the current ScopeTable# " << symbolTable->getCurrentScope()->getScopeId() << endl;
            }
        }
        else if (tokens[0] == "P" and tokenCount == 2)
        {
            if (tokens[1] == "A")
            {
                symbolTable->printAllScope();
            }
            else if (tokens[1] == "C")
            {
                symbolTable->printCurrentScope();
            }
            else
            {
                cout << "\tInvalid argument for the command P" << endl;
            }
        }
        else if (tokens[0] == "S" and tokenCount == 1)
        {
            symbolTable->enterScope();
        }
        else if (tokens[0] == "E" and tokenCount == 1)
        {
            if (symbolTable->getCurrentScope()->getParentScope() == NULL)
            {
                cout << "\tScopeTable# " << symbolTable->getCurrentScope()->getScopeId() << " cannot be deleted" << endl;
            }
            else
            {
                symbolTable->exitScope();
            }
        }
        else if (tokens[0] == "Q" and tokenCount == 1)
        {
            symbolTable->exitAllScope();
            break;
        }
        else if (tokenCount > 0 and (tokens[0] == "P" or tokens[0] == "I" or tokens[0] == "S" or tokens[0] == "E" or tokens[0] == "D" or tokens[0] == "L"))
        {
            cout << "\tWrong number of arguments for the command " << tokens[0] << endl;
        }
        else
        {
            cout << "\tInvalid command" << endl;
        }
    }
}