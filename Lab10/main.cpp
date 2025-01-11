#include <iostream>
#include <sstream>
#include <string>
#include <pqxx/pqxx>
#include "lab10.h"

using namespace std;
using namespace pqxx;

string queryToJson(connection& dbConnection, const string& query) {
    ostringstream jsonStream;
    jsonStream << "[\n";

    try {
        work transaction{dbConnection};
        result res{transaction.exec(query)};

        bool firstRow = true;
        for (const auto& row : res) {
            if (!firstRow) {
                jsonStream << ",\n";
            }
            jsonStream << "{ \n\t";

            bool firstField = true;
            for (const auto& field : row) {
                if (!firstField) {
                    jsonStream << ",\n\t";
                }
                jsonStream << "\"" << field.name() << "\":";

                if (field.is_null()) {
                    jsonStream << "null";
                } else {
                    jsonStream << "\"" << field.c_str() << "\"";
                }

                firstField = false;
            }

            jsonStream << "}";
            firstRow = false;
        }

        jsonStream << "]";
        transaction.commit();
    } catch (const sql_error& e) {
        cerr << "SQL error: " << e.what() << endl;
        cerr << "Query: " << e.query() << endl;
        throw;
    } catch (const exception& e) {
        cerr << "Error: " << e.what() << endl;
        throw;
    }

    return jsonStream.str();
}

int main(int argc, char* argv[]) {

    DBConnectionDetails dbConnectionDetails;
//    string connectionString = "dbname=your_db user=your_user password=your_password host=localhost port=5432";
    string connectionString = dbConnectionDetails.getFullConnectionString();
    string sqlQuery;

    cout << "Enter SQL query: ";
    getline(cin, sqlQuery);

    if (connectionString == ""){
        sqlQuery = "SELECT * FROM lab09.wykladowca";
    }

    try {
        connection dbConnection(connectionString);

        if (dbConnection.is_open()) {
            string jsonOutput = queryToJson(dbConnection, sqlQuery);
            cout << "Generated JSON: " << endl;
            cout << jsonOutput << endl;
        } else {
            cerr << "Could not connect to database." << endl;
            return 1;
        }
        dbConnection.disconnect();
    } catch (const exception& e) {
        cerr << e.what() << endl;
        return 1;
    }

    return 0;
}