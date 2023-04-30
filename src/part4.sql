-- ================================= DROP ============================

DROP TABLE IF EXISTS TableName_Peers CASCADE;
DROP TABLE IF EXISTS tablename_tasks CASCADE;
DROP TABLE IF EXISTS TableName_P2P CASCADE;
DROP TABLE IF EXISTS Verter CASCADE;
DROP TABLE IF EXISTS TableName_Checks CASCADE;
DROP TABLE IF EXISTS TableName_TransferredPoints CASCADE;
DROP TABLE IF EXISTS Friends CASCADE;
DROP TABLE IF EXISTS TableName_Recommendations CASCADE;
DROP TABLE IF EXISTS XP CASCADE;
DROP TABLE IF EXISTS TableName_TimeTracking CASCADE;

DROP TYPE IF EXISTS "check_status" CASCADE;
DROP TYPE IF EXISTS State CASCADE;


-- ================================= CREATE ============================

-- tablename_peers --
CREATE TABLE TableName_Peers (
    Nickname VARCHAR PRIMARY KEY,
    Birthday DATE NOT NULL
);


-- tablename_tasks --
CREATE TABLE TableName_Tasks (
    Title VARCHAR PRIMARY KEY,
    ParentTask VARCHAR NULL,
    MaxXP INTEGER DEFAULT 0,

    CONSTRAINT fk_task FOREIGN KEY  (ParentTask) REFERENCES TableName_Tasks(Title)
);

ALTER TABLE TableName_Tasks
    ADD CONSTRAINT check_maxxp
        CHECK ( MaxXP >= 0 );

-- CHECK STATUS --
CREATE TYPE "check_status" AS ENUM ('Start', 'Success', 'Failure');

-- tablename_checks --
CREATE TABLE TableName_Checks (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Task VARCHAR,
    Date DATE,

    CONSTRAINT fk_checks_tasks FOREIGN KEY (Task) REFERENCES TableName_Tasks (Title),
    CONSTRAINT fk_checks_peer FOREIGN KEY (Peer) REFERENCES TableName_Peers (Nickname)
);

-- tablename_p2p --
CREATE TABLE TableName_P2P (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    CheckingPeer VARCHAR,
    "State" check_status,
    Time TIME,

    CONSTRAINT fk_P2P_Checks FOREIGN KEY ("Check") REFERENCES TableName_Checks (ID),
    CONSTRAINT fk_P2P_Peer FOREIGN KEY (CheckingPeer) REFERENCES TableName_Peers (Nickname)
);


-- Verter --
CREATE TABLE Verter (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    "State" check_status,
    Time TIME,

    CONSTRAINT fk_Verter FOREIGN KEY ("Check") REFERENCES TableName_Checks (ID)
);


-- tablename_transferredpoints --
CREATE TABLE TableName_TransferredPoints (
    ID SERIAL PRIMARY KEY,
    CheckingPeer VARCHAR,
    CheckedPeer VARCHAR,
    PointsAmount INTEGER,

    CONSTRAINT fk_TransferredPoint_Cheeks_CheckingPeer FOREIGN KEY (CheckingPeer) REFERENCES TableName_Peers (Nickname),
    CONSTRAINT fk_TransferredPoint_Cheeks_CheckedPeer FOREIGN KEY (CheckedPeer) REFERENCES TableName_Peers (Nickname)
);


-- Friends --
CREATE TABLE Friends (
    ID SERIAL PRIMARY KEY,
    Peer1 VARCHAR,
    Peer2 VARCHAR,

    CONSTRAINT  fk_Friends_Peer1 FOREIGN KEY (Peer1) REFERENCES TableName_Peers (Nickname),
    CONSTRAINT fk_Friends_Peer2 FOREIGN KEY (Peer2) REFERENCES TableName_Peers (Nickname)
);


-- tablename_recommendations --
CREATE TABLE TableName_Recommendations (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    RecommendedPeer VARCHAR,

    CONSTRAINT fk_Recommendations_Peer FOREIGN KEY (Peer) REFERENCES TableName_Peers (Nickname),
    CONSTRAINT fk_Recommendations_RecommendedPeer FOREIGN KEY (RecommendedPeer) REFERENCES TableName_Peers (Nickname)
);


-- XP --
CREATE TABLE XP (
    ID SERIAL PRIMARY KEY,
    "Check" INTEGER,
    XPAmount INTEGER,

    CONSTRAINT ft_XP_Check FOREIGN KEY ("Check") REFERENCES TableName_Checks (ID)
);

ALTER TABLE XP
    ADD CONSTRAINT check_xpamount
        CHECK ( XPAmount >= 0 );

-- STATE --
CREATE TYPE State AS ENUM ('1', '2');


-- tablename_timetracking --
CREATE TABLE TableName_TimeTracking (
    ID SERIAL PRIMARY KEY,
    Peer VARCHAR,
    Date DATE,
    Time TIME,
    "State" State,

    CONSTRAINT fk_TimeTracking_Peer FOREIGN KEY (Peer) REFERENCES  TableName_Peers (Nickname)
);



-- ================================= INSERT ============================
INSERT INTO TableName_Peers (Nickname, Birthday)
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

INSERT INTO TableName_Tasks(Title, MaxXP)
VALUES ('C2_String+', 600);

INSERT INTO TableName_Tasks (Title, ParentTask, MaxXP)
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


INSERT INTO TableName_Checks (Peer, Task, Date)
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


INSERT INTO TableName_P2P ("Check", CheckingPeer, "State", Time)
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


INSERT INTO TableName_TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
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

INSERT INTO TableName_Recommendations (Peer, RecommendedPeer)
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


INSERT INTO TableName_TimeTracking (Peer, Date, Time, "State")
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


-- ========================== TRIGGERS AND FUNCTIONS ================
-- ================================= DROP ============================

DROP FUNCTION IF EXISTS  add_prp_check() CASCADE;
DROP FUNCTION IF EXISTS  add_verter_check() CASCADE;
DROP FUNCTION IF EXISTS  transferpoint_update_func() CASCADE;
DROP FUNCTION IF EXISTS  xp_update_func() CASCADE;
DROP TRIGGER IF EXISTS transferpoint_update_trigger ON tablename_p2p CASCADE;
DROP TRIGGER IF EXISTS xp_update_trigger ON xp CASCADE;


-- ================================= CREATE ============================

CREATE OR REPLACE  PROCEDURE add_prp_check(checkedpeer_ varchar, checkingpeer_ varchar, task_ varchar, state_ check_status, time_ TIME)
AS $$
    DECLARE new_id INTEGER ;
    BEGIN
        IF (state_ = 'Start') THEN
            insert into tablename_checks (peer, task, date) values (checkedpeer_, task_, CURRENT_DATE);
            new_id = (SELECT currval(pg_get_serial_sequence('tablename_checks','id')));
            insert into tablename_p2p ("Check", checkingpeer, "State", time) values (new_id, checkingpeer_, state_, time_);
        ELSE
            new_id = (SELECT "Check"
                      FROM tablename_p2p JOIN tablename_checks c on tablename_p2p."Check" = c.id
                      WHERE checkingpeer = checkingpeer_
                        AND "State" = 'Start'
                        AND peer  = checkedpeer_
                        AND task = task_
                        AND date = CURRENT_DATE);
            IF new_id NOTNULL THEN
                insert into tablename_p2p ("Check", checkingpeer, "State", time) values (new_id, checkingpeer_, state_, time_);
            END IF;
        END IF;
    END
$$
LANGUAGE plpgsql;


call  add_prp_check( 'matinish', 'torell', 'C6_s21_matrix', 'Start', '23:47:00');


CREATE OR REPLACE  PROCEDURE add_verter_check(checkedpeer_ varchar, task_ varchar, state_ check_status, time_ TIME)
AS $$
    DECLARE check_id INTEGER ;
    BEGIN
        check_id = (SELECT "Check"
                    FROM tablename_p2p JOIN tablename_checks ON tablename_p2p."Check" = tablename_checks.id
                    WHERE task = task_ AND "State" = 'Success'
                    ORDER BY date DESC
                    LIMIT 1);
        IF check_id IS NULL THEN
            RAISE EXCEPTION 'Нет подходящей успешной проверки tablename_p2p';
        ELSE
            insert into verter ("Check", "State", time) values (check_id, state_, time_);
        END IF;
    END
$$
LANGUAGE plpgsql;


call  add_verter_check( 'cflossie', 'C2_String+', 'Success', '23:47:00');

CREATE OR REPLACE FUNCTION transferpoint_update_func()
    RETURNS trigger AS
$$
    DECLARE checkedpeer1 VARCHAR;
BEGIN
    checkedpeer1 =  (SELECT peer FROM tablename_checks WHERE tablename_checks.id = new."Check");
    IF new."State" = 'Start' THEN
        UPDATE tablename_transferredpoints
        SET pointsamount = pointsamount + 1
        FROM tablename_p2p
        WHERE tablename_transferredpoints.checkingpeer = new.checkingpeer AND tablename_transferredpoints.checkedpeer = checkedpeer1;
        IF NOT FOUND THEN
            BEGIN
            INSERT INTO tablename_transferredpoints(checkingpeer, checkedpeer, pointsamount ) values (new.checkingpeer, checkedpeer1, 1);
            END;
        end if;
    END IF;
    RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER transferpoint_update_trigger
    AFTER INSERT
    ON tablename_p2p
    FOR EACH ROW
EXECUTE FUNCTION transferpoint_update_func();


CREATE OR REPLACE FUNCTION xp_insert_func()
    RETURNS trigger AS
$$
DECLARE
    max_xp INTEGER;
    check_success_count INTEGER;
BEGIN
    max_xp = (SELECT maxxp
               FROM tablename_tasks JOIN tablename_checks ON tablename_checks.id = new."Check"
               WHERE tablename_tasks.title = tablename_checks.task);
    check_success_count = (SELECT COUNT(*)
                           FROM verter
                           WHERE "State" = 'Success' AND verter."Check" = new."Check");

    IF NEW.xpamount <= max_xp AND check_success_count = 1
    THEN
        RETURN new;
    ELSE
        RAISE EXCEPTION 'Неправильная сумма опыта или проверка не завершилась успешно';
    END IF;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER xp_insert_trigger
    BEFORE INSERT
    ON xp
    FOR EACH ROW
EXECUTE FUNCTION xp_insert_func();


INSERT INTO xp("Check", xpamount) values(3, 350);



-- ======================================== FUNCTIONS AND PROCEDURES =========================

DROP FUNCTION IF EXISTS fnc_transferredpoints() CASCADE;

CREATE OR REPLACE FUNCTION fnc_transferredpoints()
RETURNS TABLE (
    peer1 varchar,
    peer2 varchar,
    points_amount integer
)
AS $$
BEGIN
RETURN QUERY
    SELECT
        t1.checkingpeer AS Peer1,
        t1.checkedpeer AS Peer2,
        ( CASE
            WHEN t2.pointsamount IS NULL THEN t1.pointsamount
            ELSE t1.pointsamount - t2.pointsamount
            END) AS PointsAmount
    FROM tablename_transferredpoints t1
    LEFT JOIN tablename_transferredpoints t2
        ON t2.checkedpeer = t1.checkingpeer
        AND t1.checkedpeer = t2.checkingpeer
    WHERE t2.id IS NULL OR t1.id < t2.id;
END;
$$ LANGUAGE 'plpgsql';

CREATE VIEW v_transferpoints AS
SELECT * FROM fnc_transferredpoints();


-- 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания, кол-во полученного XP
-- В таблицу включать только задания, успешно прошедшие проверку (определять по таблице tablename_checks).
-- Одна задача может быть успешно выполнена несколько раз. В таком случае в таблицу включать все успешные проверки.

DROP FUNCTION IF EXISTS fnc_peer_task_xp() CASCADE;

CREATE OR REPLACE FUNCTION fnc_peer_task_xp()
RETURNS TABLE (
    peer varchar,
    task varchar,
    xp integer
)
AS $$
BEGIN
    RETURN QUERY
    SELECT tablename_checks.peer AS Peer,
           tablename_checks.task AS Task,
           xp.xpamount AS XP
    FROM tablename_checks
         JOIN verter ON tablename_checks.id = verter."Check"
         JOIN xp ON tablename_checks.id = xp."Check"
    WHERE verter."State" = 'Success'
    ORDER BY peer;
END;
$$ LANGUAGE 'plpgsql';

CREATE VIEW v_fnc_peer_task_xp AS
SELECT * FROM fnc_peer_task_xp();


-- 3) Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
-- Параметры функции: день, например 12.05.2022.
-- Функция возвращает только список пиров.

DROP FUNCTION IF EXISTS fnc_peer_not_left_campus(this_day date) CASCADE;

CREATE OR REPLACE FUNCTION fnc_peer_not_left_campus(this_day date)
RETURNS TABLE (
    peer_not_left_campus varchar
)
AS $$
BEGIN
    RETURN QUERY
    SELECT peer
    FROM tablename_timetracking
    WHERE date = this_day
    GROUP BY date, peer
    HAVING COUNT(*) = 1;
END;
$$ LANGUAGE 'plpgsql';

CREATE VIEW v_peer_not_left_campus( this_day ) AS
SELECT * FROM fnc_peer_not_left_campus( '2022-10-03' );


-- 4) Посчитать изменение в количестве пир поинтов каждого пира по таблице tablename_transferredpoints
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP PROCEDURE IF EXISTS pr_peer_transferred_points();

CREATE OR REPLACE PROCEDURE pr_peer_transferred_points()
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_peer_transferred_points (peer VARCHAR, pointschange INTEGER);

    INSERT INTO temp_peer_transferred_points (peer, pointschange)
        SELECT checkingpeer, (arrival - expense) AS pointschange
        FROM (SELECT checkingpeer, SUM(pointsamount) AS arrival
              FROM tablename_transferredpoints
              GROUP BY checkingpeer) AS first
             JOIN (SELECT checkedpeer, SUM(pointsamount) AS expense
                   FROM tablename_transferredpoints
                   GROUP BY checkedpeer) AS second
             ON first.checkingpeer = second.checkedpeer;
END;
$$ LANGUAGE plpgsql;

CALL pr_peer_transferred_points();
SELECT * FROM temp_peer_transferred_points ORDER BY pointschange;

DROP TABLE IF EXISTS temp_peer_transferred_points;

-- 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP PROCEDURE IF EXISTS pr_peer_transferred_points_from_3_1() CASCADE;

CREATE OR REPLACE PROCEDURE pr_peer_transferred_points_from_3_1()
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_peer_transferred_points_from_3_1 (
        peer varchar,
        pointschange bigint
    );

    INSERT INTO temp_peer_transferred_points_from_3_1
        SELECT t.Peer, SUM(pointsamount) AS PointsChange
            FROM (
                SELECT Peer1 AS Peer,  points_amount AS PointsAmount
                FROM fnc_transferredpoints()

                UNION ALL

                SELECT Peer2 AS Peer, -points_amount AS PointsAmount
                FROM fnc_transferredpoints()
            ) t
        GROUP BY t.Peer
        ORDER BY PointsChange;

END;
$$ LANGUAGE plpgsql;

CALL pr_peer_transferred_points_from_3_1();
SELECT * FROM temp_peer_transferred_points_from_3_1;

DROP TABLE IF EXISTS temp_peer_transferred_points_from_3_1;


-- 6) Определить самое часто проверяемое задание за каждый день
-- При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
-- Формат вывода: день, название задания

DROP PROCEDURE IF EXISTS pr_most_checked_task() CASCADE;

CREATE OR REPLACE PROCEDURE pr_most_checked_task()
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_most_checked_task (day DATE, task VARCHAR);

    INSERT INTO temp_most_checked_task (day, task)
        SELECT first."date" AS day, first.task
        FROM (
            SELECT COUNT(*) AS count, tablename_checks.task, "date"
            FROM tablename_checks
            GROUP BY "date", tablename_checks.task
        ) AS first
        JOIN (
            SELECT mid."date", MAX(count) AS max
            FROM (
                SELECT COUNT(*) AS count, tablename_checks.task, "date"
                FROM tablename_checks
                GROUP BY "date", tablename_checks.task
            ) AS mid
            GROUP BY "date"
        ) AS second
        ON first."date" = second."date" AND first.count = second.max;
END;
$$ LANGUAGE plpgsql;

CALL pr_most_checked_task();
SELECT * FROM temp_most_checked_task;

DROP TABLE IF EXISTS temp_most_checked_task;

-- 7) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
-- Параметры процедуры: название блока, например "CPP".
-- Результат вывести отсортированным по дате завершения.
-- Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока)

DROP PROCEDURE IF EXISTS pr_peers_finished_block(taskname varchar) CASCADE;

CREATE OR REPLACE PROCEDURE pr_peers_finished_block(taskname varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_peer_finished_block (peer varchar, day date);
    INSERT INTO temp_peer_finished_block (peer, day)
        SELECT tablename_checks.peer, tablename_checks."date" AS day
        FROM tablename_checks
        JOIN verter v ON tablename_checks.id = v."Check"
        WHERE v."State" = 'Success'
            AND tablename_checks.task = (
                SELECT MAX(title)
                FROM (
                    SELECT UNNEST(REGEXP_MATCHES(tablename_checks.task, CONCAT('(', taskname, '\d.*)'))) AS title
                    FROM tablename_checks
                ) AS sub
            )
        ORDER BY tablename_checks."date";

END;
$$;

CALL pr_peers_finished_block('C');
SELECT * FROM temp_peer_finished_block;

DROP TABLE IF EXISTS temp_most_checked_task;

-- 8) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
-- Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, проверяться у которого рекомендует наибольшее число друзей.
-- Формат вывода: ник пира, ник найденного проверяющего

DROP PROCEDURE IF EXISTS pr_peers_recomendations() CASCADE;

CREATE OR REPLACE PROCEDURE pr_peers_recomendations()
AS
$$
BEGIN
    CREATE TEMPORARY TABLE temp_peers_recomendations (peer varchar, recommendedpeer varchar);

    INSERT INTO temp_peers_recomendations
    SELECT DISTINCT ON (first.peer) first.peer AS peer, first.recommendedpeer AS recommendedpeer
    FROM (
        SELECT tablename_peers.nickname AS peer, rec.recommendedpeer AS recommendedpeer, COUNT(rec.recommendedpeer) AS cnt
        FROM tablename_peers
        JOIN friends ON tablename_peers.nickname = friends.peer1 OR tablename_peers.nickname = friends.peer2
        JOIN tablename_recommendations AS rec ON (friends.peer1 = rec.peer AND friends.peer1 != tablename_peers.nickname)
                                    OR (friends.peer2 = rec.peer AND friends.peer2 != tablename_peers.nickname)
        WHERE tablename_peers.nickname != rec.recommendedpeer
        GROUP BY tablename_peers.nickname, rec.recommendedpeer
    ) AS first
    ORDER BY first.peer, first.cnt DESC;

END
$$ LANGUAGE plpgsql;

CALL pr_peers_recomendations();
SELECT * FROM temp_peers_recomendations;

DROP TABLE IF EXISTS temp_peers_recomendations;

-- 9) Определить процент пиров, которые:
-- Приступили только к блоку 1
-- Приступили только к блоку 2
-- Приступили к обоим
-- Не приступили ни к одному
-- Пир считается приступившим к блоку, если он проходил хоть одну проверку любого задания из этого блока (по таблице tablename_checks)
-- Параметры процедуры: название блока 1, например SQL, название блока 2, например A.
-- Формат вывода: процент приступивших только к первому блоку, процент приступивших только ко второму блоку, процент приступивших к обоим, процент не приступивших ни к одному


DROP PROCEDURE IF EXISTS pr_percentage_of_peers_completed_tasks() CASCADE;

CREATE OR REPLACE PROCEDURE pr_percentage_of_peers_completed_tasks(task_prefix1 varchar, task_prefix2 varchar)
LANGUAGE plpgsql AS $$
DECLARE
    all_peers bigint := (SELECT COUNT(*) FROM tablename_peers);

    starter_block1_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                    FROM tablename_peers
                                    JOIN tablename_checks ON tablename_peers.nickname = tablename_checks.peer
                                    WHERE tablename_checks.task LIKE (task_prefix1 || '%')
                                  );

    starter_block2_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                     FROM tablename_peers
                                     JOIN tablename_checks ON tablename_peers.nickname = tablename_checks.peer
                                     WHERE tablename_checks.task LIKE (task_prefix2 || '%')
                                   );

    started_both_tasks_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                         FROM tablename_peers
                                         JOIN tablename_checks ON tablename_peers.nickname = tablename_checks.peer
                                         WHERE tablename_checks.task LIKE (task_prefix1 || '%')
                                               AND peer IN (SELECT DISTINCT peer
                                                           FROM tablename_peers
                                                           JOIN tablename_checks ON tablename_peers.nickname = tablename_checks.peer
                                                           WHERE tablename_checks.task LIKE (task_prefix2 || '%'))
                                        );
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_completed_tasks_percent (
        started_block1_percent numeric,
        started_block2_percent numeric,
        started_both_tasks_percent numeric,
        didnt_start_any_task_percent numeric
    );

    INSERT INTO temp_completed_tasks_percent (
        started_block1_percent,
        started_block2_percent,
        started_both_tasks_percent,
        didnt_start_any_task_percent
    ) VALUES (
        (starter_block1_peers * 100 / all_peers)::numeric,
        (starter_block2_peers * 100 / all_peers)::numeric,
        (started_both_tasks_peers * 100 / all_peers)::numeric,
        ((all_peers - (starter_block1_peers + starter_block2_peers + started_both_tasks_peers)) * 100 / all_peers)::numeric
    );
END;
$$;

CALL pr_percentage_of_peers_completed_tasks('C', 'CPP');
SELECT * FROM temp_completed_tasks_percent;

DROP TABLE IF EXISTS temp_completed_tasks_percent;

-- 10) Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
-- Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения.
-- Формат вывода: процент пиров, успешно прошедших проверку в день рождения, процент пиров, проваливших проверку в день рождения

DROP PROCEDURE IF EXISTS proc_percent_successful_birthday() CASCADE;

CREATE OR REPLACE PROCEDURE proc_percent_successful_birthday()
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_percent_successful_birthday(
        successful_checks_percent DECIMAL,
        unsuccessful_checks_percent DECIMAL
    );

    INSERT INTO temp_percent_successful_birthday
        SELECT
            ROUND(100.0 * COUNT(DISTINCT CASE WHEN date_part('month', tablename_peers.Birthday) = date_part('month', tablename_checks.Date) AND date_part('day', tablename_peers.Birthday) = date_part('day', tablename_checks.Date) AND tablename_p2p."State" = 'Success' THEN tablename_checks.Peer END) / COUNT(DISTINCT CASE WHEN date_part('month', tablename_peers.Birthday) = date_part('month', tablename_checks.Date) AND date_part('day', tablename_peers.Birthday) = date_part('day', tablename_checks.Date) THEN tablename_checks.Peer END), 2) AS successful_checks_percent,
            ROUND(100.0 * COUNT(DISTINCT CASE WHEN date_part('month', tablename_peers.Birthday) = date_part('month', tablename_checks.Date) AND date_part('day', tablename_peers.Birthday) = date_part('day', tablename_checks.Date) AND tablename_p2p."State" = 'Failure' THEN tablename_checks.Peer END) / COUNT(DISTINCT CASE WHEN date_part('month', tablename_peers.Birthday) = date_part('month', tablename_checks.Date) AND date_part('day', tablename_peers.Birthday) = date_part('day', tablename_checks.Date) THEN tablename_checks.Peer END), 2) AS unsuccessful_checks_percent
        FROM
            tablename_p2p
            JOIN tablename_checks ON tablename_p2p."Check" = tablename_checks.ID
            JOIN tablename_peers ON tablename_peers.Nickname = tablename_checks.Peer;
END;
$$ LANGUAGE plpgsql;

CALL proc_percent_successful_birthday();
SELECT * FROM temp_percent_successful_birthday;

DROP TABLE IF EXISTS temp_percent_successful_birthday;

-- 11) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
-- Параметры процедуры: названия заданий 1, 2 и 3.
-- Формат вывода: список пиров

DROP PROCEDURE IF EXISTS pr_find_peers_with_completed_tasks(first_task varchar, second_task varchar, third_task varchar) CASCADE;

CREATE OR REPLACE PROCEDURE pr_find_peers_with_completed_tasks(first_task varchar, second_task varchar, third_task varchar)
AS
$$
BEGIN
    CREATE TEMPORARY TABLE temp_completed_tasks (peer varchar);

    INSERT INTO temp_completed_tasks
        SELECT c.peer
        FROM tablename_checks c
            JOIN tablename_p2p p ON c.id = p."Check"
            JOIN verter v ON c.id = v."Check"
        WHERE c.task = first_task
            AND v."State" = 'Success'
            AND p."State" = 'Success'
        INTERSECT
        SELECT c.peer
        FROM tablename_checks c
            JOIN tablename_p2p p ON c.id = p."Check"
            JOIN verter v ON c.id = v."Check"
        WHERE c.task = second_task
            AND v."State" = 'Success'
            AND p."State" = 'Success'
        EXCEPT
        SELECT c.peer
        FROM tablename_checks c
            JOIN tablename_p2p p ON c.id = p."Check"
            JOIN verter v ON c.id = v."Check"
        WHERE c.task = third_task
            AND v."State" = 'Failure'
            AND p."State" = 'Failure';
END;
$$ LANGUAGE plpgsql;

CALL pr_find_peers_with_completed_tasks('C2_String+', 'C3_SimpleBashUtils', 'C4_s21_Math');
SELECT * FROM temp_completed_tasks;

DROP TABLE IF EXISTS temp_completed_tasks;


-- 12) Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
-- То есть сколько задач нужно выполнить, исходя из условий входа, чтобы получить доступ к текущей.
-- Формат вывода: название задачи, количество предшествующих

DROP PROCEDURE IF EXISTS proc_tasks_preceding_count() CASCADE;

CREATE OR REPLACE PROCEDURE proc_tasks_preceding_count()
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_tasks_preceding_count(
        title varchar,
        count integer
    );

    WITH RECURSIVE preceding_tasks AS (
        SELECT tablename_tasks.Title, ParentTask, 0 AS Count FROM tablename_tasks WHERE ParentTask IS NULL
        UNION
        SELECT tablename_tasks.Title, tablename_tasks.ParentTask, preceding_tasks.Count + 1 AS Count
        FROM tablename_tasks
        JOIN preceding_tasks ON preceding_tasks.Title = tablename_tasks.ParentTask
    )
    INSERT INTO temp_tasks_preceding_count (title, count)
    SELECT tablename_tasks.Title, MAX(preceding_tasks.Count) AS Count
    FROM tablename_tasks
    JOIN preceding_tasks ON preceding_tasks.Title = tablename_tasks.Title
    GROUP BY tablename_tasks.Title
    ORDER BY Count DESC;

END;
$$;

CALL proc_tasks_preceding_count();
SELECT * FROM temp_tasks_preceding_count;

DROP TABLE IF EXISTS temp_tasks_preceding_count;

-- 13) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
-- Параметры процедуры: количество идущих подряд успешных проверок N.
-- Временем проверки считать время начала tablename_p2p этапа.
-- Под идущими подряд успешными проверками подразумеваются успешные проверки, между которыми нет неуспешных.
-- При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального.
-- Формат вывода: список дней

DROP PROCEDURE IF EXISTS pr_success_checks(count_checks integer) CASCADE;

CREATE OR REPLACE PROCEDURE pr_success_checks(count_checks integer)
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_success_checks (check_date date);

    INSERT INTO temp_success_checks
        SELECT c1.date
        FROM tablename_checks c1
        JOIN tablename_tasks ON c1.task = tablename_tasks.title
        JOIN xp ON c1.id = xp."Check"
        JOIN (SELECT "Check", MAX("State") AS "State" FROM verter GROUP BY "Check") v ON c1.id = v."Check"
        WHERE v."State" = 'Success' AND ((xp.xpamount::real / tablename_tasks.maxxp::real) * 100) >= 80
        GROUP BY c1.date
        HAVING COUNT(*) >= count_checks
        ORDER BY c1.date;
END;
$$ LANGUAGE plpgsql;

CALL  pr_success_checks(2);
SELECT * FROM temp_success_checks;

DROP TABLE IF EXISTS temp_success_checks;


-- 14) Определить пира с наибольшим количеством XP
-- Формат вывода: ник пира, количество XP

DROP PROCEDURE IF EXISTS pr_most_xp_peer() CASCADE;

CREATE OR REPLACE PROCEDURE pr_most_xp_peer()
AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_xp (peer varchar, xp_amount bigint);

    INSERT INTO temp_xp
        SELECT tablename_checks.peer, SUM(xp.xpamount)
        FROM tablename_checks
        JOIN tablename_p2p ON tablename_checks.id = tablename_p2p."Check"
        JOIN verter ON tablename_checks.id = verter."Check"
        JOIN xp ON tablename_checks.id = xp."Check"
        WHERE verter."State" = 'Success' AND tablename_p2p."State" = 'Success'
        GROUP BY tablename_checks.peer
        ORDER BY SUM(xp.xpamount) DESC
        LIMIT 1;

    COMMIT;
END;
$$ LANGUAGE plpgsql;


CALL pr_most_xp_peer();
SELECT * FROM temp_xp;

DROP TABLE IF EXISTS temp_xp;

-- 15) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
-- Параметры процедуры: время, количество раз N.
-- Формат вывода: список пиров

DROP PROCEDURE IF EXISTS pr_early_arrivals_by_peer(check_time TIME, n_times BIGINT, OUT peer VARCHAR) CASCADE;

CREATE OR REPLACE PROCEDURE pr_early_arrivals_by_peer(
    check_time TIME, n_times BIGINT
) AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_early_arrivals (
        peer VARCHAR
    );

    INSERT INTO temp_early_arrivals
    SELECT tablename_timetracking.peer
    FROM tablename_timetracking
    WHERE "time" < check_time
        AND tablename_timetracking."State" = '1'
    GROUP BY tablename_timetracking.peer
    HAVING COUNT(tablename_timetracking."State") >= n_times;

END;
$$ LANGUAGE plpgsql;

CALL pr_early_arrivals_by_peer('9:50', '1');
SELECT * FROM temp_early_arrivals;

DROP TABLE IF EXISTS temp_early_arrivals;

-- 16) Определить пиров, выходивших за последние N дней из кампуса больше M раз
-- Параметры процедуры: количество дней N, количество раз M.
-- Формат вывода: список пиров

DROP PROCEDURE IF EXISTS pr_peers_exiting_campus(n INTEGER, m INTEGER) CASCADE;

CREATE OR REPLACE PROCEDURE pr_peers_exiting_campus(n INTEGER, m INTEGER) AS $$
BEGIN
    CREATE TEMPORARY TABLE temp_table AS
        SELECT DISTINCT tablename_timetracking.peer
        FROM tablename_timetracking
        WHERE tablename_timetracking."State" = '2' AND date >= (CURRENT_DATE - n)
        GROUP BY tablename_timetracking.peer
        HAVING COUNT(*) >= m;

    PERFORM * FROM temp_table ORDER BY peer;
END;
$$ LANGUAGE plpgsql;

CALL pr_peers_exiting_campus(1000, 1);
SELECT * FROM temp_table;

DROP TABLE IF EXISTS  temp_table;

-- 17) Определить для каждого месяца процент ранних входов
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус за всё время (будем называть это общим числом входов).
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус раньше 12:00 за всё время (будем называть это числом ранних входов).
-- Для каждого месяца посчитать процент ранних входов в кампус относительно общего числа входов.
-- Формат вывода: месяц, процент ранних входов

DROP PROCEDURE IF EXISTS pr_early_came_percent() CASCADE;

CREATE OR REPLACE PROCEDURE pr_early_came_percent() AS $$
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_early_came_percent (
        month TEXT,
        earlyentries BIGINT
    );

    WITH months AS (
        SELECT ROW_NUMBER() OVER () AS number, TO_CHAR(gs, 'Month') AS month
        FROM (SELECT generate_series AS gs
            FROM GENERATE_SERIES('2021-01-01', '2023-12-31', INTERVAL '1 month')) AS series
    )
    INSERT INTO temp_early_came_percent (month, earlyentries)
    SELECT months.month,
        COALESCE(
            (
                SELECT COUNT(*) * 100 / NULLIF(
                    (
                        SELECT COUNT(*)
                        FROM tablename_timetracking
                        JOIN tablename_peers ON tablename_peers.nickname = tablename_timetracking.peer
                        WHERE tablename_timetracking."State" = '1'
                            AND (SELECT SUBSTRING(TO_CHAR(tablename_timetracking.date, 'yyyy-mm-dd') FROM 6 FOR 2)) =
                                (SELECT SUBSTRING(TO_CHAR(tablename_peers.birthday, 'yyyy-mm-dd') FROM 6 FOR 2))
                            AND number = EXTRACT(MONTH FROM tablename_timetracking.date)
                    ),
                    0
                )
                FROM tablename_peers
                JOIN tablename_timetracking ON tablename_peers.nickname = tablename_timetracking.peer
                WHERE (SELECT SUBSTRING(TO_CHAR(tablename_timetracking.date, 'yyyy-mm-dd') FROM 6 FOR 2)) =
                    (SELECT SUBSTRING(TO_CHAR(tablename_peers.birthday, 'yyyy-mm-dd') FROM 6 FOR 2))
                AND tablename_timetracking."State" = '1'
                AND EXTRACT(HOURS FROM tablename_timetracking.time) < 12
                AND number = EXTRACT(MONTH FROM tablename_timetracking.date)
            ),
            0
        ) AS earlyentries
    FROM months;

END;
$$ LANGUAGE plpgsql;

CALL pr_early_came_percent();
SELECT * FROM temp_early_came_percent;

DROP TABLE IF EXISTS temp_early_came_percent;


CREATE OR REPLACE FUNCTION tablename_sum(a INTEGER, b INTEGER) RETURNS INTEGER AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;

-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================

-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================

-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================
-- ===========================  PART 4 ========================================


-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных, уничтожает все те таблицы
-- текущей базы данных, имена которых начинаются с фразы 'TableName'.

DROP PROCEDURE IF EXISTS drop_tables_starting_with_name() CASCADE;

CREATE OR REPLACE PROCEDURE drop_tables_starting_with_name()
LANGUAGE plpgsql
AS $$
DECLARE
    table_name text;
BEGIN
    FOR table_name IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'tablename%' LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || table_name || ' CASCADE';
    END LOOP;
END;
$$;

CALL drop_tables_starting_with_name();

-- 2) Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров
-- всех скалярных SQL функций пользователя в текущей базе данных. Имена функций без параметров не выводить.
-- Имена и список параметров должны выводиться в одну строку. Выходной параметр возвращает количество найденных функций.

DROP PROCEDURE IF EXISTS pr_function_information(OUT out_amount INTEGER) CASCADE;

CREATE OR REPLACE PROCEDURE pr_function_information(OUT out_amount INTEGER)
AS
$$
DECLARE
    cur CURSOR FOR SELECT * FROM function_info;
    rec record;
BEGIN
    CREATE TEMPORARY TABLE function_info (
        routine_info TEXT
    );

    INSERT INTO function_info (routine_info)
    SELECT r.routine_name || '; ' || STRING_AGG(p.parameter_name || ' ' || p.data_type, ', ')
    FROM information_schema.routines r
        JOIN information_schema.parameters p ON r.specific_name = p.specific_name
    WHERE r.specific_schema = 'public'
        AND r.routine_type = 'FUNCTION'
        AND p.parameter_mode = 'IN'
        AND p.data_type <> 'information_schema.sql_identifier'
    GROUP BY r.routine_name
    HAVING COUNT(p.parameter_name) > 0
    ORDER BY r.routine_name;

    GET DIAGNOSTICS out_amount = ROW_COUNT;

    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', rec.routine_info;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    num_functions INTEGER;
BEGIN
    CALL pr_function_information(num_functions);
    RAISE INFO 'Total functions: %', num_functions;
END $$;


-- 3) Создать хранимую процедуру с выходным параметром, которая уничтожает все SQL DML
-- триггеры в текущей базе данных. Выходной параметр возвращает количество уничтоженных триггеров.

DROP PROCEDURE IF EXISTS pr_drop_dml_triggers(OUT out_amount INTEGER) CASCADE;

CREATE OR REPLACE PROCEDURE pr_drop_dml_triggers(OUT out_amount INTEGER)
AS
$$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT event_object_schema, event_object_table, trigger_name
                  FROM information_schema.triggers
                  WHERE trigger_schema = 'public'
                  AND event_manipulation IN ('INSERT', 'UPDATE', 'DELETE');
BEGIN
    out_amount := 0;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        EXECUTE 'DROP TRIGGER ' || rec.trigger_name || ' ON ' || rec.event_object_schema || '.' || rec.event_object_table;
        out_amount := out_amount + 1;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    num_triggers INTEGER;
    cur CURSOR FOR SELECT event_object_schema, event_object_table, trigger_name
                  FROM information_schema.triggers
                  WHERE trigger_schema = 'public'
                  AND event_manipulation IN ('INSERT', 'UPDATE', 'DELETE');
    rec RECORD;
BEGIN
    CALL pr_drop_dml_triggers(num_triggers);
    RAISE INFO 'Number of deleted triggers: %', num_triggers;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Deleted trigger % on table %.%', rec.trigger_name, rec.event_object_schema, rec.event_object_table;
    END LOOP;
    CLOSE cur;
END $$;


-- 4) Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов
-- (только хранимых процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая
-- параметром процедуры.