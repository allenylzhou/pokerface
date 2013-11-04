DROP TABLE PAYMENT_PART;
DROP TABLE BACKING;
DROP TABLE BACKING_AGREEMENT;
DROP TABLE GAME_CASH;
DROP TABLE GAME_TOURNAMENT;
DROP TABLE GAME;
DROP TABLE LOCATION;
DROP TABLE USERS_RELATIONSHIP;
DROP TABLE USERS_RELATIONSHIP_TYPE;
DROP TABLE USERS;

drop sequence game_sequence;
drop sequence users_sequence;

CREATE TABLE USERS 
(
  USER_ID NUMBER(10) NOT NULL
, USERNAME VARCHAR2(24 CHAR) 
, PASSWORD VARCHAR2(32) 
, CONSTRAINT USERS_PK PRIMARY KEY ( USER_ID ) ENABLE 
, CONSTRAINT USERS_UK_USERNAME UNIQUE ( USERNAME ) ENABLE
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
	ENABLE
);


CREATE TABLE GAME_TOURNAMENT
(
  GS_ID NUMBER(20) NOT NULL 
, PLACED_FINISHED NUMBER(5,0)
, CONSTRAINT GAME_TOURN_PK PRIMARY KEY ( GS_ID ) ENABLE 
, CONSTRAINT GAME_TOURN_GAME_FK1 
	FOREIGN KEY ( GS_ID ) 
	REFERENCES GAME ( GS_ID )
	ENABLE
);


CREATE TABLE BACKING_AGREEMENT 
(
  ID NUMBER(20) NOT NULL 
, HORSE_ID NUMBER(20) NOT NULL 
, BACKER_ID NUMBER(20)
, FLAT_FEE NUMBER(8, 2) DEFAULT 0 
, PERCENT_OF_WIN NUMBER(5, 2) DEFAULT 0
, PERCENT_OF_LOSS NUMBER(5, 2) DEFAULT 0
, OVERRIDE_AMOUNT NUMBER(8, 2) 
, CONSTRAINT BACKING_AGREEMENT_PK PRIMARY KEY ( ID ) ENABLE 
, CONSTRAINT BACKING_AGREE_USERS_FK1 
	FOREIGN KEY ( HORSE_ID ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT BACKING_AGREE_USERS_FK2 
	FOREIGN KEY ( BACKER_ID ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
);


CREATE TABLE BACKING 
(
  ID NUMBER(20) NOT NULL 
, GS_ID NUMBER(20) NOT NULL
, CONSTRAINT BACKING_PK PRIMARY KEY ( ID , GS_ID ) ENABLE 
, CONSTRAINT BACKING_BACKING_AGREE_FK1 
	FOREIGN KEY ( ID ) 
	REFERENCES BACKING_AGREEMENT ( ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT BACKING_GAME_FK1
	FOREIGN KEY ( GS_ID ) 
	REFERENCES GAME ( GS_ID )
	ENABLE
);


CREATE TABLE USERS_RELATIONSHIP_TYPE 
(
  URT_ID NUMBER(2) NOT NULL 
, DESCRIPTION VARCHAR2(20) NOT NULL 
, CONSTRAINT USERS_RELATIONSHIP_TYPE_PK PRIMARY KEY ( URT_ID  ) ENABLE 
, CONSTRAINT USERS_RELATIONSHIP_TYPE_UK1 UNIQUE ( DESCRIPTION ) ENABLE
);


CREATE TABLE USERS_RELATIONSHIP 
(
  USER_TO NUMBER(10) NOT NULL 
, USER_FROM NUMBER(10) NOT NULL 
, URT_ID NUMBER(2) NOT NULL 
, CONSTRAINT USERS_RELATIONSHIP_PK PRIMARY KEY ( USER_TO , USER_FROM , URT_ID ) ENABLE 
, CONSTRAINT USERS_RELATIONSHIP_USERS_FK1 
	FOREIGN KEY ( USER_TO ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT USERS_RELATIONSHIP_USERS_FK2 
	FOREIGN KEY ( USER_FROM ) 
	REFERENCES USERS ( USER_ID )
	ON DELETE CASCADE ENABLE
, CONSTRAINT USERS_RELATIONSHIP_URT_FK1 
	FOREIGN KEY ( URT_ID ) 
	REFERENCES USERS_RELATIONSHIP_TYPE ( URT_ID )
	ON DELETE CASCADE ENABLE
);


CREATE TABLE PAYMENT_PART 
(
  ID NUMBER(20) NOT NULL
, GS_ID NUMBER(20) NOT NULL 
, PAYMENT_SUBPART NUMBER(2) NOT NULL 
, AMOUNT NUMBER(8, 2) NOT NULL 
, CONSTRAINT PAYMENT_PART_PK PRIMARY KEY ( ID , GS_ID , PAYMENT_SUBPART  ) ENABLE 
, CONSTRAINT PAYMENT_PART_BACKING_FK1 
	FOREIGN KEY ( ID , GS_ID ) 
	REFERENCES BACKING ( ID , GS_ID )
	ENABLE
);


CREATE SEQUENCE USERS_SEQUENCE INCREMENT BY 1 START WITH 0 MAXVALUE 20000 MINVALUE 0 NOCACHE;
CREATE SEQUENCE GAME_SEQUENCE INCREMENT BY 1 START WITH 0 MAXVALUE 20000 MINVALUE 0 NOCACHE;

INSERT INTO USERS (USER_ID, USERNAME,PASSWORD) VALUES (0,'A','A');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD) VALUES (1,'B','B');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD) VALUES (2,'C','C');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD) VALUES (3,'D','D');
INSERT INTO USERS (USER_ID, USERNAME,PASSWORD) VALUES (4,'E','E');

INSERT INTO USERS_RELATIONSHIP_TYPE (URT_ID, DESCRIPTION) VALUES (0, 'FRIENDS WITH');
INSERT INTO USERS_RELATIONSHIP_TYPE (URT_ID, DESCRIPTION) VALUES (1, 'CAN BACK');
INSERT INTO USERS_RELATIONSHIP_TYPE (URT_ID, DESCRIPTION) VALUES (2, 'BLOCKED');
INSERT INTO USERS_RELATIONSHIP_TYPE (URT_ID, DESCRIPTION) VALUES (3, 'CAN VIEW');
INSERT INTO USERS_RELATIONSHIP_TYPE (URT_ID, DESCRIPTION) VALUES (4, 'CAN VIEW EMAIL');


INSERT INTO USERS_RELATIONSHIP (USER_TO, USER_FROM, URT_ID) VALUES (0, 1, 0);
INSERT INTO USERS_RELATIONSHIP (USER_TO, USER_FROM, URT_ID) VALUES (1, 2, 0);
INSERT INTO USERS_RELATIONSHIP (USER_TO, USER_FROM, URT_ID) VALUES (2, 3, 0);
INSERT INTO USERS_RELATIONSHIP (USER_TO, USER_FROM, URT_ID) VALUES (3, 4, 0);
INSERT INTO USERS_RELATIONSHIP (USER_TO, USER_FROM, URT_ID) VALUES (4, 0, 0);


INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (0, 'A', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (1, 'B', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (2, 'C', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (3, 'D', 1);
INSERT INTO LOCATION (USER_ID, NAME, FAVOURITE) VALUES (3, 'E', 1);


INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (0, 0, TO_DATE('01-01-2013', 'DD-MM-YYYY'), 
TO_DATE('01-01-2013', 'DD-MM-YYYY'), 100, 0, 'A');
INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (1, 0, TO_DATE('01-01-2013', 'DD-MM-YYYY'), 
TO_DATE('01-01-2013', 'DD-MM-YYYY'), 10, 10, 'A');
INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (2, 0, TO_DATE('01-01-2013', 'DD-MM-YYYY'), 
TO_DATE('01-01-2013', 'DD-MM-YYYY'), 100, 0, 'A');
INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (3, 0, TO_DATE('01-01-2013', 'DD-MM-YYYY'), 
TO_DATE('01-01-2013', 'DD-MM-YYYY'), 20, 10, 'A');
INSERT INTO GAME (GS_ID, USER_ID, START_DATE, END_DATE, AMOUNT_IN, AMOUNT_OUT, LOCATION_NAME) 
VALUES (4, 0, TO_DATE('01-01-2013', 'DD-MM-YYYY'), 
TO_DATE('01-01-2013', 'DD-MM-YYYY'), 100, 0, 'A');


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


INSERT INTO BACKING_AGREEMENT (ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (0, 0, 0, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (1, 1, 0, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (2, 2, null, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (3, 3, null, 10, 10, 10, NULL);
INSERT INTO BACKING_AGREEMENT (ID, HORSE_ID, BACKER_ID, FLAT_FEE, PERCENT_OF_WIN, PERCENT_OF_LOSS, OVERRIDE_AMOUNT) 
VALUES (4, 4, null, NULL, NULL, NULL, 10);



INSERT INTO BACKING (ID ,GS_ID) 
VALUES (0, 0);
INSERT INTO BACKING (ID ,GS_ID) 
VALUES (0, 1);
INSERT INTO BACKING (ID ,GS_ID) 
VALUES (0, 2);
INSERT INTO BACKING (ID ,GS_ID) 
VALUES (0, 3);
INSERT INTO BACKING (ID ,GS_ID) 
VALUES (0, 4);


INSERT INTO PAYMENT_PART (ID, GS_ID, PAYMENT_SUBPART, AMOUNT) VALUES (0, 0, 1, 3);
INSERT INTO PAYMENT_PART (ID, GS_ID, PAYMENT_SUBPART, AMOUNT) VALUES (0, 0, 2, 3);
INSERT INTO PAYMENT_PART (ID, GS_ID, PAYMENT_SUBPART, AMOUNT) VALUES (0, 0, 3, 3);
INSERT INTO PAYMENT_PART (ID, GS_ID, PAYMENT_SUBPART, AMOUNT) VALUES (0, 1, 1, 3);
INSERT INTO PAYMENT_PART (ID, GS_ID, PAYMENT_SUBPART, AMOUNT) VALUES (0, 1, 2, 3);
