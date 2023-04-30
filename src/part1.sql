-- ================================= DROP ============================

DROP TABLE IF EXISTS Peers CASCADE;
DROP TABLE IF EXISTS Tasks CASCADE;
DROP TABLE IF EXISTS P2P CASCADE;
DROP TABLE IF EXISTS Verter CASCADE;
DROP TABLE IF EXISTS Checks CASCADE;
DROP TABLE IF EXISTS TransferredPoints CASCADE;
DROP TABLE IF EXISTS Friends CASCADE;
DROP TABLE IF EXISTS Recommendations CASCADE;
DROP TABLE IF EXISTS XP CASCADE;
DROP TABLE IF EXISTS TimeTracking CASCADE;

DROP TYPE IF EXISTS "check_status" CASCADE;
DROP TYPE IF EXISTS State CASCADE;


-- ================================= CREATE ============================

-- PEERS --
CREATE TABLE Peers (
    Nickname VARCHAR PRIMARY KEY,
    Birthday DATE NOT NULL
);


-- TASKS --
CREATE TABLE Tasks (
    Title VARCHAR PRIMARY KEY,
    ParentTask VARCHAR NULL,
    MaxXP INTEGER DEFAULT 0,

    CONSTRAINT fk_task FOREIGN KEY  (ParentTask) REFERENCES Tasks(Title)
);

ALTER TABLE Tasks
    ADD CONSTRAINT check_maxxp
        CHECK ( MaxXP >= 0 );

-- CHECK STATUS --
CREATE TYPE "check_status" AS ENUM ('Start', 'Success', 'Failure');

-- Checks --
CREATE TABLE Checks (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Task VARCHAR,
    Date DATE,

    CONSTRAINT fk_checks_tasks FOREIGN KEY (Task) REFERENCES Tasks (Title),
    CONSTRAINT fk_checks_peer FOREIGN KEY (Peer) REFERENCES Peers (Nickname)
);

-- P2P --
CREATE TABLE P2P (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    CheckingPeer VARCHAR,
    "State" check_status,
    Time TIME,

    CONSTRAINT fk_P2P_Checks FOREIGN KEY ("Check") REFERENCES Checks (ID),
    CONSTRAINT fk_P2P_Peer FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname)
);


-- Verter --
CREATE TABLE Verter (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    "State" check_status,
    Time TIME,

    CONSTRAINT fk_Verter FOREIGN KEY ("Check") REFERENCES Checks (ID)
);


-- TransferredPoints --
CREATE TABLE TransferredPoints (
    ID SERIAL PRIMARY KEY,
    CheckingPeer VARCHAR,
    CheckedPeer VARCHAR,
    PointsAmount INTEGER,

    CONSTRAINT fk_TransferredPoint_Cheeks_CheckingPeer FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
    CONSTRAINT fk_TransferredPoint_Cheeks_CheckedPeer FOREIGN KEY (CheckedPeer) REFERENCES Peers (Nickname)
);


-- Friends --
CREATE TABLE Friends (
    ID SERIAL PRIMARY KEY,
    Peer1 VARCHAR,
    Peer2 VARCHAR,

    CONSTRAINT  fk_Friends_Peer1 FOREIGN KEY (Peer1) REFERENCES Peers (Nickname),
    CONSTRAINT fk_Friends_Peer2 FOREIGN KEY (Peer2) REFERENCES Peers (Nickname)
);


-- Recommendations --
CREATE TABLE Recommendations (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    RecommendedPeer VARCHAR,

    CONSTRAINT fk_Recommendations_Peer FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    CONSTRAINT fk_Recommendations_RecommendedPeer FOREIGN KEY (RecommendedPeer) REFERENCES Peers (Nickname)
);


-- XP --
CREATE TABLE XP (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    XPAmount INTEGER,

    CONSTRAINT ft_XP_Check FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

ALTER TABLE XP
    ADD CONSTRAINT check_xpamount
        CHECK ( XPAmount >= 0 );

-- STATE --
CREATE TYPE State AS ENUM ('1', '2');


-- TimeTracking --
CREATE TABLE TimeTracking (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Date DATE,
    Time TIME,
    "State" State,

    CONSTRAINT fk_TimeTracking_Peer FOREIGN KEY (Peer) REFERENCES  Peers (Nickname)
);



-- ================================= INSERT ============================
INSERT INTO Peers (Nickname, Birthday)
VALUES ('torell', '1993-08-01'),
       ('cflossie', '1993-03-18'),
       ('matinish', '2002-09-11'),
       ('kcresswe', '2000-11-02'),
       ('sblushin', '1994-02-14'),
       ('gconn', '2002-06-05'),
       ('tcocoa', '1995-02-25'),
       ('acandela', '1994-02-25'),
       ('aedie', '1993-03-12'),
       ('hspeaker', '1998-06-25'),
       ('ebonicra', '2000-08-13');

INSERT INTO Tasks(Title, MaxXP)
VALUES ('C2_String+', 600);

INSERT INTO Tasks (Title, ParentTask, MaxXP)
VALUES ('C3_SimpleBashUtils', 'C2_String+', 250),
       ('C4_s21_Math', 'C3_SimpleBashUtils', 500),
       ('C5_s21_decimal', 'C4_s21_Math', 300),
       ('C6_s21_matrix', 'C5_s21_decimal', 350),
       ('C7_SmartCalculator', 'C6_s21_matrix', 700),
       ('C8_3D_Viewer_v1.0', 'C7_SmartCalculator', 1020),
       ('CPP_s21_matrix+', 'C8_3D_Viewer_v1.0', 300),
       ('CPP_s21_containers', 'CPP_s21_matrix+', 501),
       ('CPP_SmartCalculator_v2.0', 'CPP_s21_containers', 750),
       ('CPP_3D_Viewer_v2.0', 'CPP_SmartCalculator_v2.0', 1050),
       ('CPP_MLP', 'CPP_3D_Viewer_v2.0', 700),
       ('A1_Maze', 'CPP_MLP', 300),
       ('A2_SimpleNavigator_v1.0', 'A1_Maze', 400),
       ('A3_Parallels', 'A2_SimpleNavigator_v1.0', 300),
       ('A4_Transactions', 'A3_Parallels', 700),
       ('A5_Algorithmic_trading', 'A4_Transactions', 800);


INSERT INTO Checks (Peer, Task, Date)
VALUES ('cflossie', 'C2_String+','2021-10-01'),
       ('cflossie', 'C3_SimpleBashUtils','2021-11-01'),
       ('gconn', 'C2_String+','2021-12-01'),
       ('matinish', 'C4_s21_Math','2021-12-02'),
       ('torell', 'C2_String+', '2021-12-03'),
       ('cflossie', 'C4_s21_Math','2021-12-04'),
        ('cflossie', 'C5_s21_decimal','2022-01-04'),
        ('cflossie', 'C6_s21_matrix','2022-01-14'),
        ('cflossie', 'C7_SmartCalculator','2022-01-31'),
        ('cflossie', 'C8_3D_Viewer_v1.0','2022-02-10'),
        ('cflossie', 'CPP_s21_matrix+','2022-02-20'),
        ('cflossie', 'CPP_SmartCalculator_v2.0','2022-02-28'),
        ('tcocoa', 'C2_String+','2021-02-25'),
        ('torell', 'C3_SimpleBashUtils', '2021-08-01'),
        ('gconn', 'C3_SimpleBashUtils','2021-12-10'),
        ('gconn', 'C4_s21_Math','2021-12-20'),
        ('tcocoa', 'C3_SimpleBashUtils','2021-12-20'),
        ('kcresswe', 'C2_String+','2021-12-20');


INSERT INTO P2P ("Check", CheckingPeer, "State", Time)
VALUES (1, 'matinish', 'Start', '4:20'),
       (1, 'matinish', 'Success', '4:50'),
       (2, 'gconn', 'Start', '16:20'),
       (2, 'gconn', 'Success', '16:50'),
       (3, 'matinish', 'Start', '19:00'),
       (3, 'matinish', 'Success', '19:30'),
       (4, 'tcocoa', 'Start', '21:00'),
       (4, 'tcocoa', 'Failure', '21:10'),
       (5, 'cflossie', 'Start', '17:30'),
       (5, 'cflossie', 'Failure', '17:31'),
       (6, 'torell', 'Start', '6:20'),
       (6, 'torell', 'Success', '6:50'),
        (7, 'tcocoa', 'Start', '10:20'),
        (7, 'tcocoa', 'Success', '10:50'),
        (8, 'acandela', 'Start', '3:20'),
        (8, 'acandela', 'Success', '3:50'),
        (9, 'hspeaker', 'Start', '5:20'),
        (9, 'hspeaker', 'Success', '5:50'),
        (10, 'aedie', 'Start', '8:20'),
        (10, 'aedie', 'Success', '8:50'),
        (11, 'acandela', 'Start', '19:20'),
        (11, 'acandela', 'Success', '19:50'),
        (12, 'acandela', 'Start', '18:20'),
        (12, 'acandela', 'Success', '18:50'),
        (13, 'aedie', 'Start', '15:20'),
        (13, 'aedie', 'Success', '15:50'),
        (14, 'cflossie', 'Start', '16:20'),
        (14, 'cflossie', 'Failure', '16:50'),
        (15, 'matinish', 'Start', '21:20'),
        (15, 'matinish', 'Success', '21:50'),
        (16, 'acandela', 'Start', '22:20'),
        (16, 'acandela', 'Failure', '22:50'),
        (17, 'hspeaker', 'Start', '22:50'),
        (17, 'hspeaker', 'Success', '23:20'),
        (18, 'sblushin', 'Start', '10:50'),
        (18, 'sblushin', 'Success', '11:20');


INSERT INTO Verter ("Check", "State", Time)
VALUES (1, 'Start', '4:51'),
       (1, 'Success', '4:52'),
       (2, 'Start', '16:51'),
       (2, 'Success', '16:52'),
       (3, 'Start', '19:31'),
       (3, 'Success', '19:32'),
       (6, 'Start', '6:51'),
       (6, 'Failure', '6:52'),
        (7, 'Start', '10:51'),
        (7, 'Success', '10:52'),
        (8, 'Start', '3:51'),
        (8, 'Success', '3:52'),
        (9, 'Start', '5:51'),
        (9, 'Success', '5:52'),
        (10, 'Start', '8:51'),
        (10, 'Success', '8:52'),
        (11, 'Start', '19:51'),
        (11, 'Success', '19:52'),
        (12, 'Start', '18:51'),
        (12, 'Success', '18:52'),
        (13, 'Start', '15:51'),
        (13, 'Success', '15:52'),
        (15, 'Start', '21:51'),
        (15, 'Success', '21:52'),
        (17, 'Start', '23:21'),
        (17, 'Success', '23:22'),
        (18, 'Start', '11:21'),
        (18, 'Success', '11:22');


INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
VALUES ('matinish', 'cflossie', 1),
       ('gconn', 'cflossie',  1),
       ('matinish', 'gconn',  1),
       ('tcocoa', 'matinish', 1),
       ('cflossie', 'torell', 1),
       ('torell', 'cflossie', 1),
        ('tcocoa', 'cflossie', 1),
        ('acandela', 'cflossie', 1),
        ('hspeaker', 'cflossie', 1),
        ('aedie', 'cflossie', 1),
        ('acandela', 'cflossie', 1),
        ('acandela', 'cflossie', 1),
        ('aedie', 'tcocoa', 1),
        ('cflossie', 'torell', 1),
        ('matinish', 'gconn', 1),
        ('acandela', 'gconn', 1),
        ('sblushin', 'kcresswe', 1);


INSERT INTO Friends (Peer1, Peer2)
VALUES ('cflossie', 'matinish'),
       ('cflossie', 'gconn'),
       ('gconn', 'matinish'),
       ('matinish', 'tcocoa'),
       ('gconn', 'tcocoa'),
       ('cflossie', 'acandela'),
       ('cflossie', 'aedie'),
       ('matinish', 'torell'),
       ('matinish', 'acandela'),
       ('gconn', 'acandela'),
       ('hspeaker', 'acandela'),
       ('hspeaker', 'tcocoa'),
       ('hspeaker', 'cflossie');

INSERT INTO Recommendations (Peer, RecommendedPeer)
VALUES ('cflossie', 'matinish'),
       ('cflossie', 'gconn'),
       ('gconn', 'matinish'),
       ('matinish', 'tcocoa'),
       ('gconn', 'tcocoa'),
       ('gconn', 'acandela'),
       ('cflossie', 'acandela'),
       ('torell', 'acandela'),
        ('torell', 'tcocoa'),
        ('aedie', 'tcocoa'),
        ('hspeaker', 'tcocoa'),
        ('cflossie', 'hspeaker'),
        ('aedie', 'hspeaker');

INSERT INTO XP ("Check", XPAmount)
VALUES (1, 600),
       (2, 250),
       (3, 350),
       (7, 300),
       (8, 340),
       (9, 650),
       (10, 1020),
       (11, 300),
       (12, 730),
       (13, 600),
       (15, 250),
       (17, 250),
       (18, 580);


INSERT INTO TimeTracking (Peer, Date, Time, "State")
VALUES ('cflossie', '2021-10-01', '4:20', '1'),
       ('cflossie', '2021-10-01', '4:50', '2'),
       ('cflossie', '2021-10-01', '5:23', '1'),
       ('cflossie', '2021-10-01', '6:50', '2'),
       ('gconn', '2021-10-02', '10:00', '1'),
       ('gconn', '2021-10-02', '10:30', '2'),
       ('gconn', '2021-10-02', '11:00', '1'),
       ('gconn', '2021-10-02', '11:30', '2'),
       ('torell', '2022-10-02', '11:00', '1'),
       ('torell', '2022-10-02', '11:30', '2'),
       ('tcocoa', '2022-10-03', '00:01', '1'),

        ('cflossie', '2022-01-04', '00:01', '1'),
        ('cflossie', '2022-01-04', '23:01', '2'),
        ('cflossie', '2022-01-14', '00:01', '1'),
        ('cflossie', '2022-01-14', '23:45', '2'),
        ('cflossie', '2022-01-31', '00:01', '1'),
        ('cflossie', '2022-01-31', '23:10', '2'),
        ('cflossie', '2022-02-10', '00:01', '1'),
        ('cflossie', '2022-02-10', '23:11', '2'),
        ('cflossie', '2022-02-20', '00:01', '1'),
        ('cflossie', '2022-02-20', '23:30', '2'),
        ('cflossie', '2022-02-28', '00:01', '1'),
        ('cflossie', '2022-02-28', '23:30', '2'),
        ('cflossie', '2022-03-18', '00:01', '1'),
        ('cflossie', '2022-03-18', '23:30', '2'),
        ('cflossie', '2022-03-19', '00:01', '1'),
        ('cflossie', '2022-03-19', '23:30', '2'),
         ('cflossie', '2022-03-20', '15:01', '1'),
         ('cflossie', '2022-03-20', '23:30', '2'),
        ('torell', '2022-08-01', '11:30', '1'),
        ('torell', '2022-08-01', '23:01', '2'),
        ('torell', '2022-08-02', '11:30', '1'),
        ('torell', '2022-08-02', '23:01', '2'),
        ('torell', '2022-08-03', '11:30', '1'),
        ('torell', '2022-08-03', '23:01', '2'),
        ('torell', '2022-08-04', '13:30', '1'),
        ('torell', '2022-08-04', '20:01', '2'),
        ('tcocoa', '2022-02-25', '00:01', '1'),
        ('tcocoa', '2022-02-25', '23:01', '2'),
        ('tcocoa', '2022-02-26', '18:01', '1'),
        ('tcocoa', '2022-02-26', '23:01', '2'),
        ('tcocoa', '2022-02-27', '14:01', '1'),
        ('tcocoa', '2022-02-27', '23:01', '2'),
        ('matinish', '2022-09-11', '00:01', '1'),
        ('matinish', '2022-09-11', '16:01', '2'),
        ('hspeaker', '2022-06-25', '11:01', '1'),
        ('hspeaker', '2022-06-25', '23:01', '2'),
        ('hspeaker', '2022-06-26', '17:01', '1'),
        ('hspeaker', '2022-06-26', '23:01', '2'),
        ('hspeaker', '2022-06-27', '00:01', '1'),
        ('hspeaker', '2022-06-27', '23:01', '2');

-- ================================= IMPORT ============================
CREATE OR REPLACE PROCEDURE Import_from_CSV(path text)
AS $$
DECLARE
    input_str text;
BEGIN
    input_str:= 'COPY Peers(Nickname, Birthday) FROM ''' || path || '/peer.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Tasks(Title, ParentTask, MaxXP) FROM ''' || path || '/task.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Checks(Peer, Task, Date) FROM ''' || path || '/checks.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY P2P("Check", CheckingPeer, "State", Time) FROM ''' || path || '/P2P.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY TimeTracking(Peer, Date, Time, "State") FROM ''' || path || '/timetracking.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Verter("Check", "State", Time) FROM ''' || path || '/verter.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY TransferredPoints(CheckingPeer, CheckedPeer, PointsAmount) FROM ''' || path || '/transferredpoints.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Friends(Peer1, Peer2) FROM ''' || path || '/friends.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Recommendations(Peer, RecommendedPeer) FROM ''' || path || '/recommendations.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY XP("Check", XPAmount) FROM ''' || path || '/xp.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
END;
$$
LANGUAGE plpgsql;


CALL Import_from_CSV('/Users/dimasava/SCHOOL_21/SQL/SQL2_Info21_v1.0-0/src/csv');


-- ================================= EXPORT ============================
CREATE OR REPLACE PROCEDURE Export_from_CSV(path text)
AS $$
DECLARE
    input_str text;
BEGIN
    input_str:= 'COPY Peers(Nickname, Birthday) TO ''' || path || '/peer.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Tasks(Title, ParentTask, MaxXP) TO ''' || path || '/task.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY P2P("Check", CheckingPeer, "State", Time) TO ''' || path || '/P2P.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY TimeTracking(Peer, Date, Time, "State") TO ''' || path || '/timetracking.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Verter("Check", "State", Time) TO ''' || path || '/verter.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Checks(Peer, Task, Date) TO ''' || path || '/checks.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY TransferredPoints(CheckingPeer, CheckedPeer, PointsAmount) TO ''' || path || '/transferredpoints.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Friends(Peer1, Peer2) TO ''' || path || '/friends.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY Recommendations(Peer, RecommendedPeer) TO ''' || path || '/recommendations.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
    input_str:= 'COPY XP("Check", XPAmount) TO ''' || path || '/xp.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE input_str;
END;
$$
LANGUAGE plpgsql;


CALL Export_from_CSV('/Users/dimasava/SCHOOL_21/SQL/SQL2_Info21_v1.0-0/src/test1');

