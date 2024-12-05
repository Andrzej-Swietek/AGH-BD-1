/* Processed by ecpg (17.0 (Debian 17.0-1.pgdg120+1)) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "test.sqc"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "test.h"


#line 1 "/usr/include/postgresql/sqlca.h"
#ifndef POSTGRES_SQLCA_H
#define POSTGRES_SQLCA_H

#ifndef PGDLLIMPORT
#if  defined(WIN32) || defined(__CYGWIN__)
#define PGDLLIMPORT __declspec (dllimport)
#else
#define PGDLLIMPORT
#endif							/* __CYGWIN__ */
#endif							/* PGDLLIMPORT */

#define SQLERRMC_LEN	150

#ifdef __cplusplus
extern "C"
{
#endif

struct sqlca_t
{
	char		sqlcaid[8];
	long		sqlabc;
	long		sqlcode;
	struct
	{
		int			sqlerrml;
		char		sqlerrmc[SQLERRMC_LEN];
	}			sqlerrm;
	char		sqlerrp[8];
	long		sqlerrd[6];
	/* Element 0: empty						*/
	/* 1: OID of processed tuple if applicable			*/
	/* 2: number of rows processed				*/
	/* after an INSERT, UPDATE or				*/
	/* DELETE statement					*/
	/* 3: empty						*/
	/* 4: empty						*/
	/* 5: empty						*/
	char		sqlwarn[8];
	/* Element 0: set to 'W' if at least one other is 'W'	*/
	/* 1: if 'W' at least one character string		*/
	/* value was truncated when it was			*/
	/* stored into a host variable.             */

	/*
	 * 2: if 'W' a (hopefully) non-fatal notice occurred
	 */	/* 3: empty */
	/* 4: empty						*/
	/* 5: empty						*/
	/* 6: empty						*/
	/* 7: empty						*/

	char		sqlstate[5];
};

struct sqlca_t *ECPGget_sqlca(void);

#ifndef POSTGRES_ECPG_INTERNAL
#define sqlca (*ECPGget_sqlca())
#endif

#ifdef __cplusplus
}
#endif

#endif

#line 6 "test.sqc"

/* exec sql whenever sql_warning  sqlprint ; */
#line 7 "test.sqc"

/* exec sql whenever sqlerror  do Prnt ( ) ; */
#line 8 "test.sqc"



void Prnt() {
    fprintf(stderr, "*******************************************\n");
    fprintf(stderr, "Fatal Error\n");
    sqlprint();
    fprintf(stderr, "*******************************************\n");
}

/* exec sql begin declare section */

     //*db
     //*usr
     //*pas







#line 19 "test.sqc"
 char dbname [ 1024 ] ;

#line 20 "test.sqc"
 char db [ 200 ] ;

#line 21 "test.sqc"
 char usr [ 15 ] ;

#line 22 "test.sqc"
 char pas [ 30 ] ;

#line 24 "test.sqc"
 int wykladowca_id ;

#line 25 "test.sqc"
 char kurs [ 100 ] ;

#line 26 "test.sqc"
 int ilosc_prowadzacych ;

#line 27 "test.sqc"
 char nazwisko [ 100 ] ;

#line 28 "test.sqc"
 char stan [ 15 ] ;
/* exec sql end declare section */
#line 29 "test.sqc"


int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <wykladowca_id>\n", argv[0]);
        return 1;
    }

    strncpy(db,dbase,200);//db = dbase
    strncpy(usr,user,15);//usr = user
    strncpy(pas,pass,30);//pas = pass
    wykladowca_id = atoi(argv[1]);

    { ECPGconnect(__LINE__, 0, db , usr , pas , NULL, 0);
#line 42 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 42 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 42 "test.sqc"

    if (sqlca.sqlcode < 0) {
        Prnt();
        return 1;
    }

    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "select current_database ( )", ECPGt_EOIT,
	ECPGt_char,(dbname),(long)1024,(long)1,(1024)*sizeof(char),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 48 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 48 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 48 "test.sqc"

    printf("current database=%s \n", dbname);

    printf("[");

    /* declare kurs_cursor cursor for select k . nazwa , count ( wk . wykladowca_id ) , w . nazwisko , case when k . koniec is null then 'nieukonczony' else 'ukonczony' end from lab09 . wykladowca_kurs wk join lab09 . kurs k on wk . kurs_id = k . kurs_id join lab09 . wykladowca w on wk . wykladowca_id = w . wykladowca_id where wk . kurs_id in ( select kurs_id from lab09 . wykladowca_kurs where wykladowca_id = $1  ) group by k . nazwa , k . koniec , w . nazwisko order by k . nazwa */
#line 68 "test.sqc"


    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "declare kurs_cursor cursor for select k . nazwa , count ( wk . wykladowca_id ) , w . nazwisko , case when k . koniec is null then 'nieukonczony' else 'ukonczony' end from lab09 . wykladowca_kurs wk join lab09 . kurs k on wk . kurs_id = k . kurs_id join lab09 . wykladowca w on wk . wykladowca_id = w . wykladowca_id where wk . kurs_id in ( select kurs_id from lab09 . wykladowca_kurs where wykladowca_id = $1  ) group by k . nazwa , k . koniec , w . nazwisko order by k . nazwa",
	ECPGt_int,&(wykladowca_id),(long)1,(long)1,sizeof(int),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);
#line 70 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 70 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 70 "test.sqc"


    int is_first = 1;
    while (1) {
        { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "fetch kurs_cursor", ECPGt_EOIT,
	ECPGt_char,(kurs),(long)100,(long)1,(100)*sizeof(char),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L,
	ECPGt_int,&(ilosc_prowadzacych),(long)1,(long)1,sizeof(int),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L,
	ECPGt_char,(nazwisko),(long)100,(long)1,(100)*sizeof(char),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L,
	ECPGt_char,(stan),(long)15,(long)1,(15)*sizeof(char),
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 74 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 74 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 74 "test.sqc"

        if (sqlca.sqlcode == 100) break; // No more rows
        if (sqlca.sqlcode < 0) {
            Prnt();
            break;
        }

        // Output JSON
        if (!is_first) printf(",");
        is_first = 0;
        printf("{\"kurs\":\"%s\",\"ilosc_prowadzacych\":%d,\"prowadzacy\":[{\"nazwisko\":\"%s\"}],\"stan\":\"%s\"}",
               kurs, ilosc_prowadzacych, nazwisko, stan);
    }

    printf("]\n");

    { ECPGdo(__LINE__, 0, 1, NULL, 0, ECPGst_normal, "close kurs_cursor", ECPGt_EOIT, ECPGt_EORT);
#line 90 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 90 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 90 "test.sqc"

    { ECPGdisconnect(__LINE__, "ALL");
#line 91 "test.sqc"

if (sqlca.sqlwarn[0] == 'W') sqlprint();
#line 91 "test.sqc"

if (sqlca.sqlcode < 0) Prnt ( );}
#line 91 "test.sqc"


    return 0;
}