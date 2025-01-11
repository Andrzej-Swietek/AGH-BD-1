#pragma once

#include <stdio.h>
#include <string.h>
#include <sstream>


struct DBConnectionDetails {
    std::string DB_NAME;
    std::string DB_USER;
    std::string DB_PASS;
    std::string DB_HOST;
    std::string DB_PORT;

    DBConnectionDetails() {
        this->DB_NAME = "neondb";
        this->DB_USER = "db_user";
        this->DB_PASS = "db_pass";
        this->DB_HOST = "ep-young-wave-61044232.us-east-2.aws.neon.tech";
        this->DB_PORT = "5432";
    }

    std::string getFullConnectionString(){
        using namespace std;

        stringstream ss;
        ss << "dbname = " << this->DB_NAME \
           << " user = " << this->DB_USER \
           << " password = " << this->DB_PASS \
           << " host = " << this->DB_HOST \
           << " port = " << this->DB_PORT;
        std::string result = ss.str();
        return result;
    }
};