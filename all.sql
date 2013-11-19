DROP VIEW V_DEBT_STATUS;
DROP TABLE PAYMENT;
DROP TABLE BACKING;
DROP TABLE BACKING_AGREEMENT;
DROP TABLE GAME_CASH;
DROP TABLE GAME_TOURNAMENT;
DROP TABLE GAME;
DROP TABLE LOCATION;
DROP TABLE HORSE_BACKERS;
DROP TABLE USERS;

DROP SEQUENCE GAME_SEQUENCE;
DROP SEQUENCE USERS_SEQUENCE;
DROP SEQUENCE BACKING_AGREEMENT_SEQUENCE;
DROP SEQUENCE PAYMENT_SEQUENCE;

CREATE TABLE USERS 
(
  USER_ID NUMBER(10) NOT NULL
, USERNAME VARCHAR2(24 CHAR) NOT NULL
, PASSWORD VARCHAR2(32) NOT NULL 
, EMAIL VARCHAR2(50 CHAR) NOT NULL
, CONSTRAINT USERS_PK PRIMARY KEY ( USER_ID ) ENABLE 
, CONSTRAINT USERS_UK_USERNAME UNIQUE ( USERNAME ) ENABLE
, CONSTRAINT USERS_UK_EMAIL UNIQUE ( EMAIL ) ENABLE
, CONSTRAINT USERNAMELENGTH CHECK(LENGTH(USERNAME) > 2) ENABLE
, CONSTRAINT EMAILREGEX CHECK(REGEXP_LIKE(EMAIL,'\w+@\w+(\.\w+)+')) ENABLE
);


CREATE TABLE LOCATION
(
  USER_ID NUMBER(20) NOT NULL
, NAME VARCHAR2(50 CHAR) NOT NULL 
, FAVOURITE SMALLINT 
, CONSTRAINT LOCATIONA_PK PRIMARY KEY ( USER_ID  , NAME  ) ENABLE 
, CONSTRAINT LOCATION_USERS_FK1 
	FOREIGN KEY ( USER_ID ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
);


CREATE TABLE GAME
(
  GS_ID NUMBER(20) NOT NULL
, USER_ID NUMBER(10) 
, START_DATE DATE
, END_DATE DATE
, AMOUNT_IN NUMBER(9,2) NOT NULL
, AMOUNT_OUT NUMBER(9,2) NOT NULL
, LOCATION_NAME VARCHAR2(50)
, CONSTRAINT GAME_PK PRIMARY KEY ( GS_ID ) ENABLE 
, CONSTRAINT GAME_USERS_FK1 
	FOREIGN KEY ( USER_ID ) 
	REFERENCES USERS ( USER_ID )
	ENABLE
, CONSTRAINT LOCATION_GAME_FK1
	FOREIGN KEY ( USER_ID , LOCATION_NAME ) 
	REFERENCES LOCATION ( USER_ID , NAME )
	ON DELETE SET NULL ENABLE
);


CREATE TABLE GAME_CASH 
(
  GS_ID NUMBER(20) NOT NULL 
, BIG_BLIND NUMBER(6, 2) 
, SMALL_BLIND NUMBER(6, 2) 
, CONSTRAINT GAME_CASH_PK PRIMARY KEY ( GS_ID ) ENABLE 
, CONSTRAINT GAME_CASH_GAME_FK1 
	FOREIGN KEY ( GS_ID ) 
	REFERENCES GAME ( GS_ID )
	ON DELETE CASCADE ENABLE
);


CREATE TABLE GAME_TOURNAMENT
(
  GS_ID NUMBER(20) NOT NULL 
, PLACED_FINISHED NUMBER(5,0)
, CONSTRAINT GAME_TOURN_PK PRIMARY KEY ( GS_ID ) ENABLE 
, CONSTRAINT GAME_TOURN_GAME_FK1 
	FOREIGN KEY ( GS_ID ) 
	REFERENCES GAME ( GS_ID )
	ON DELETE CASCADE ENABLE
);

CREATE TABLE HORSE_BACKERS 
(
  HORSE NUMBER(20) NOT NULL 
, BACKER NUMBER(20) NOT NULL 
, CONSTRAINT HORSE_BACKERS_PK PRIMARY KEY ( HORSE , BACKER ) ENABLE 
, CONSTRAINT HORSE_BACKERS_FK1 
	FOREIGN KEY ( HORSE ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT HORSE_BACKERS_FK2 
	FOREIGN KEY ( BACKER ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT HORSE_BACKERS_DIFF CHECK(HORSE != BACKER) ENABLE
);

CREATE TABLE BACKING_AGREEMENT 
(
  BA_ID NUMBER(20) NOT NULL 
, HORSE_ID NUMBER(20) NOT NULL 
, BACKER_ID NUMBER(20) NOT NULL 
, FLAT_FEE NUMBER(8, 2) DEFAULT 0 
, PERCENT_OF_WIN NUMBER(5, 2) DEFAULT 0
, PERCENT_OF_LOSS NUMBER(5, 2) DEFAULT 0
, OVERRIDE_AMOUNT NUMBER(8, 2) 
, CONSTRAINT BACKING_AGREEMENT_PK PRIMARY KEY ( BA_ID ) ENABLE 
, CONSTRAINT BACKING_AGREEMENT_U UNIQUE ( HORSE_ID , BACKER_ID , FLAT_FEE , PERCENT_OF_WIN , PERCENT_OF_LOSS , OVERRIDE_AMOUNT ) ENABLE
, CONSTRAINT BACKING_AGREE_USERS_FK1 
	FOREIGN KEY ( HORSE_ID , BACKER_ID )
	REFERENCES HORSE_BACKERS ( HORSE , BACKER )
	ON DELETE CASCADE ENABLE
, CONSTRAINT BACKING_AGREE_DIFF CHECK(HORSE_ID != BACKER_ID) ENABLE
, CONSTRAINT BACKING_AGREE_FEE CHECK(FLAT_FEE >= 0) ENABLE
, CONSTRAINT BACKING_AGREE_POW CHECK(PERCENT_OF_WIN >= 0 AND PERCENT_OF_WIN <= 100) ENABLE
, CONSTRAINT BACKING_AGREE_POL CHECK(PERCENT_OF_LOSS >= 0 AND PERCENT_OF_LOSS <= 100) ENABLE
);


CREATE TABLE BACKING 
(
  BA_ID NUMBER(20) NOT NULL 
, GS_ID NUMBER(20) NOT NULL
, CONSTRAINT BACKING_PK PRIMARY KEY ( BA_ID , GS_ID ) ENABLE 
, CONSTRAINT BACKING_BACKING_AGREE_FK1 
	FOREIGN KEY ( BA_ID ) 
	REFERENCES BACKING_AGREEMENT ( BA_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT BACKING_GAME_FK1
	FOREIGN KEY ( GS_ID ) 
	REFERENCES GAME ( GS_ID )
	ENABLE
);


CREATE TABLE PAYMENT
(
  PP_ID NUMBER(20) NOT NULL
, PAYER_ID NUMBER(20) NOT NULL
, PAYEE_ID NUMBER(20) NOT NULL 
, PAYMENT_DATE DATE NOT NULL
, AMOUNT NUMBER(8, 2) NOT NULL 
, CONSTRAINT PAYMENT_PK PRIMARY KEY ( PP_ID  ) ENABLE 
, CONSTRAINT PAYMENT_FK1 
	FOREIGN KEY ( PAYER_ID ) 
	REFERENCES USERS ( USER_ID )
	ENABLE
, CONSTRAINT PAYMENT_FK2
	FOREIGN KEY ( PAYEE_ID ) 
	REFERENCES USERS ( USER_ID )
	ENABLE
, CONSTRAINT PAYMENT_DIFFERENT_USER CHECK(PAYER_ID != PAYEE_ID) ENABLE
, CONSTRAINT PAYMENT_AMOUNT_VALID CHECK(AMOUNT > 0) ENABLE
);


CREATE SEQUENCE USERS_SEQUENCE INCREMENT BY 1 START WITH 10 MAXVALUE 20000 MINVALUE 0 NOCACHE;
CREATE SEQUENCE GAME_SEQUENCE INCREMENT BY 1 START WITH 10 MAXVALUE 20000 MINVALUE 0 NOCACHE;
CREATE SEQUENCE BACKING_AGREEMENT_SEQUENCE INCREMENT BY 1 START WITH 10 MAXVALUE 20000 MINVALUE 0 NOCACHE;
CREATE SEQUENCE PAYMENT_SEQUENCE INCREMENT BY 1 START WITH 10 MAXVALUE 20000 MINVALUE 0 NOCACHE;


CREATE VIEW V_DEBT_STATUS AS 
	WITH USER_GAME_HISTORY AS (
		SELECT USER_ID,
			GS_ID, 
			AMOUNT_OUT-AMOUNT_IN AS CHANGE
		FROM	GAME),	
    USER_PAYMENTS AS (
      SELECT PAYER_ID, PAYEE_ID, SUM(AMOUNT) AS PAYED
      FROM PAYMENT
      GROUP BY PAYER_ID, PAYEE_ID
    )
    SELECT BA.HORSE_ID,
			BA.BACKER_ID,
    SUM(CASE 
      WHEN BA.OVERRIDE_AMOUNT IS NOT NULL THEN BA.OVERRIDE_AMOUNT
      WHEN G.CHANGE > 0 THEN (G.CHANGE * BA.PERCENT_OF_WIN/100) + BA.FLAT_FEE
      ELSE (G.CHANGE * BA.PERCENT_OF_LOSS/100 * -1) + BA.FLAT_FEE
    END) AS OWED, 
    NVL(UP.PAYED,0) AS PAYED 
    FROM BACKING B, USER_GAME_HISTORY G, BACKING_AGREEMENT BA, USER_PAYMENTS UP
    WHERE B.BA_ID = BA.BA_ID
		AND G.GS_ID = B.GS_ID
		AND UP.PAYER_ID (+) = BA.HORSE_ID
		AND UP.PAYEE_ID (+) = BA.BACKER_ID
    GROUP BY BA.HORSE_ID,
			BA.BACKER_ID,
			NVL(UP.PAYED,0);
      

INSERT INTO USERS (USER_ID, USERNAME,PASSWORD,EMAIL) VALUES (0,'AAA','A', 'A@D.COM');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD,EMAIL) VALUES (1,'BBB','B', 'A1@AA.COM');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD,EMAIL) VALUES (2,'CCC','C', 'A1@ASDF.COM');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD,EMAIL) VALUES (3,'DDD','D', 'DFDS@A.COM');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD,EMAIL) VALUES (4,'EEE','E', 'ASDF@A.COM');


INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (0, 1);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (0, 2);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (1, 2);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (1, 3);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (1, 4);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (2, 2);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (2, 3);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (2, 4);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (3, 4);
INSERT INTO HORSE_BACKERS (HORSE, BACKER) VALUES (4, 3);


INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (0, 'A', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (1, 'B', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (2, 'C', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (3, 'D', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (3, 'E', 1);


INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (0, 0, TO_DATE('01-01-2013 08:30:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('01-01-2013 10:30:00', 'DD-MM-YYYY HH24:MI:SS'), 100, 0, 'A');

INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (1, 0, TO_DATE('01-01-2013 14:00:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('01-01-2013 16:00:00', 'DD-MM-YYYY HH24:MI:SS'), 10, 10, 'A');

INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (2, 0, TO_DATE('01-01-2013 15:00:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('01-01-2013 17:00:00', 'DD-MM-YYYY HH24:MI:SS'), 100, 0, 'A');

INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (3, 0, TO_DATE('01-01-2013 17:00:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('01-01-2013 19:00:00', 'DD-MM-YYYY HH24:MI:SS'), 20, 10, 'A');

INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (4, 0, TO_DATE('01-01-2013 19:00:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('01-01-2013 21:00:00', 'DD-MM-YYYY HH24:MI:SS'), 100, 0, 'A');

INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (5, 0, TO_DATE('04-10-2013 21:00:00', 'DD-MM-YYYY HH24:MI:SS'), 
TO_DATE('04-10-2013 23:20:00', 'DD-MM-YYYY HH24:MI:SS'), 100, 0, 'A');

INSERT INTO GAME_CASH (GS_ID, BIG_BLIND, SMALL_BLIND) VALUES (0, 1, 2);
INSERT INTO GAME_CASH (GS_ID, BIG_BLIND, SMALL_BLIND) VALUES (1, 1, 2);
INSERT INTO GAME_CASH (GS_ID, BIG_BLIND, SMALL_BLIND) VALUES (2, 1, 3);
INSERT INTO GAME_CASH (GS_ID, BIG_BLIND, SMALL_BLIND) VALUES (3, 1, 4);
INSERT INTO GAME_CASH (GS_ID, BIG_BLIND, SMALL_BLIND) VALUES (4, 1, 5);


INSERT INTO GAME_TOURNAMENT (GS_ID, PLACED_FINISHED) VALUES (0, 1);
INSERT INTO GAME_TOURNAMENT (GS_ID, PLACED_FINISHED) VALUES (1, 1);
INSERT INTO GAME_TOURNAMENT (GS_ID, PLACED_FINISHED) VALUES (2, 2);
INSERT INTO GAME_TOURNAMENT (GS_ID, PLACED_FINISHED) VALUES (3, 1);
INSERT INTO GAME_TOURNAMENT (GS_ID, PLACED_FINISHED) VALUES (4, 3);


INSERT INTO BACKING_AGREEMENT (BA_ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (0, 0, 1, 10, 10, 10, 5);
INSERT INTO BACKING_AGREEMENT (BA_ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (1, 0, 2, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (BA_ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (2, 2, 3, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (BA_ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (3, 3, 4, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (BA_ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (4, 4, 3, NULL, NULL, NULL, 10);



INSERT INTO BACKING (BA_ID ,GS_ID) 
VALUES (0, 0);
INSERT INTO BACKING (BA_ID ,GS_ID) 
VALUES (0, 1);
INSERT INTO BACKING (BA_ID ,GS_ID) 
VALUES (0, 2);
INSERT INTO BACKING (BA_ID ,GS_ID) 
VALUES (0, 3);
INSERT INTO BACKING (BA_ID ,GS_ID) 
VALUES (0, 4);


INSERT INTO PAYMENT (PP_ID, PAYER_ID, PAYEE_ID, PAYMENT_DATE, AMOUNT) VALUES (0, 0, 1, SYSDATE, 3);
INSERT INTO PAYMENT (PP_ID, PAYER_ID, PAYEE_ID, PAYMENT_DATE, AMOUNT) VALUES (1, 0, 1, SYSDATE-1, 3);
INSERT INTO PAYMENT (PP_ID, PAYER_ID, PAYEE_ID, PAYMENT_DATE, AMOUNT) VALUES (2, 0, 1, SYSDATE-2, 3);
INSERT INTO PAYMENT (PP_ID, PAYER_ID, PAYEE_ID, PAYMENT_DATE, AMOUNT) VALUES (3, 1, 0, SYSDATE-3, 3);
INSERT INTO PAYMENT (PP_ID, PAYER_ID, PAYEE_ID, PAYMENT_DATE, AMOUNT) VALUES (4, 1, 2, SYSDATE, 3);
