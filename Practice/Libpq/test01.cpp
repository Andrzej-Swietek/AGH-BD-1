#include <iostream>
#include <sstream>
#include <string>
#include <pqxx/pqxx>
#include "lab10.h"

using namespace std;
using namespace pqxx;

int main(int argc, char* argv[]) {

    DBConnectionDetails dbConnectionDetails;
    string connectionString = dbConnectionDetails.getFullConnectionString();

    try {
        connection connlab(connectionString);
        if (connlab.is_open()) {

            work trsxn{connlab};

            result res { trsxn.exec("SELECT id, fname, lname FROM lab10.person") };
            for (auto row: res)
            std::cout << row["id"].as<int>() << " " << row[2].c_str() << " " << row[1].c_str() << std::endl;

            // dla polecenia select niekoniecznie
            trsxn.commit();

        } else {
            std::cout << "Problem z connection " << endl;
            return 3;
        }
        connlab.disconnect();
    } catch (pqxx::sql_error const &e) {
        cerr << "SQL error: " << e.what() << std::endl;
        cerr << "Polecenie SQL: " << e.query() << std::endl;
        return 2;
    } catch (const std::exception &e) {
        cerr << e.what() << std::endl;
        return 1;
    }
}
