#pragma once;

#include <stdio.h>
#include <string.h>
#include <sstream>


struct DBConnectionDetails {
    const std::string DB_NAME = "neondb@ep-young-wave-61044232.us-east-2.aws.neon.tech";
    const std::string DB_USER = "";
    const std::string DB_PASS = "";
    const std::string DB_HOST = "";
    const std::string DB_PORT = "";

    std::string getFullConnectionString(){
        stringstream ss;
        ss << "dbname = " << this.DB_NAME \
           << " user = " << this.DB_USER \
           << " password = " << this.DB_PASS \
           << " host = " << this.DB_HOST \
           << " port = " << this.DB_PORT;
        std::string result = ss.str();
        return result;
    }
};