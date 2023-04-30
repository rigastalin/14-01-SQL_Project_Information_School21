-- 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
-- Ник пира 1, ник пира 2, количество переданных пир поинтов.
-- Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.

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
    FROM transferredpoints t1
    LEFT JOIN transferredpoints t2
        ON t2.checkedpeer = t1.checkingpeer
        AND t1.checkedpeer = t2.checkingpeer
    WHERE t2.id IS NULL OR t1.id < t2.id;
END;
$$ LANGUAGE 'plpgsql';

CREATE VIEW v_transferpoints AS
SELECT * FROM fnc_transferredpoints();


-- 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания, кол-во полученного XP
-- В таблицу включать только задания, успешно прошедшие проверку (определять по таблице Checks).
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
    SELECT checks.peer AS Peer,
           checks.task AS Task,
           xp.xpamount AS XP
    FROM checks
         JOIN verter ON checks.id = verter."Check"
         JOIN xp ON checks.id = xp."Check"
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
    FROM timetracking
    WHERE date = this_day
    GROUP BY date, peer
    HAVING COUNT(*) = 1;
END;
$$ LANGUAGE 'plpgsql';

CREATE VIEW v_peer_not_left_campus( this_day ) AS
SELECT * FROM fnc_peer_not_left_campus( '2022-10-03' );


-- 4) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
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
              FROM transferredpoints
              GROUP BY checkingpeer) AS first
             JOIN (SELECT checkedpeer, SUM(pointsamount) AS expense
                   FROM transferredpoints
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
            SELECT COUNT(*) AS count, checks.task, "date"
            FROM checks
            GROUP BY "date", checks.task
        ) AS first
        JOIN (
            SELECT mid."date", MAX(count) AS max
            FROM (
                SELECT COUNT(*) AS count, checks.task, "date"
                FROM checks
                GROUP BY "date", checks.task
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
        SELECT checks.peer, checks."date" AS day
        FROM checks
        JOIN verter v ON checks.id = v."Check"
        WHERE v."State" = 'Success'
            AND checks.task = (
                SELECT MAX(title)
                FROM (
                    SELECT UNNEST(REGEXP_MATCHES(checks.task, CONCAT('(', taskname, '\d.*)'))) AS title
                    FROM checks
                ) AS sub
            )
        ORDER BY checks."date";

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
        SELECT peers.nickname AS peer, rec.recommendedpeer AS recommendedpeer, COUNT(rec.recommendedpeer) AS cnt
        FROM peers
        JOIN friends ON peers.nickname = friends.peer1 OR peers.nickname = friends.peer2
        JOIN recommendations AS rec ON (friends.peer1 = rec.peer AND friends.peer1 != peers.nickname)
                                    OR (friends.peer2 = rec.peer AND friends.peer2 != peers.nickname)
        WHERE peers.nickname != rec.recommendedpeer
        GROUP BY peers.nickname, rec.recommendedpeer
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
-- Пир считается приступившим к блоку, если он проходил хоть одну проверку любого задания из этого блока (по таблице Checks)
-- Параметры процедуры: название блока 1, например SQL, название блока 2, например A.
-- Формат вывода: процент приступивших только к первому блоку, процент приступивших только ко второму блоку, процент приступивших к обоим, процент не приступивших ни к одному


DROP PROCEDURE IF EXISTS pr_percentage_of_peers_completed_tasks() CASCADE;

CREATE OR REPLACE PROCEDURE pr_percentage_of_peers_completed_tasks(task_prefix1 varchar, task_prefix2 varchar)
LANGUAGE plpgsql AS $$
DECLARE
    all_peers bigint := (SELECT COUNT(*) FROM peers);

    starter_block1_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                    FROM peers
                                    JOIN checks ON peers.nickname = checks.peer
                                    WHERE checks.task LIKE (task_prefix1 || '%')
                                  );

    starter_block2_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                     FROM peers
                                     JOIN checks ON peers.nickname = checks.peer
                                     WHERE checks.task LIKE (task_prefix2 || '%')
                                   );

    started_both_tasks_peers bigint := ( SELECT COUNT(DISTINCT peer)
                                         FROM peers
                                         JOIN checks ON peers.nickname = checks.peer
                                         WHERE checks.task LIKE (task_prefix1 || '%')
                                               AND peer IN (SELECT DISTINCT peer
                                                           FROM peers
                                                           JOIN checks ON peers.nickname = checks.peer
                                                           WHERE checks.task LIKE (task_prefix2 || '%'))
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
            ROUND(100.0 * COUNT(DISTINCT CASE WHEN date_part('month', peers.Birthday) = date_part('month', checks.Date) AND date_part('day', peers.Birthday) = date_part('day', checks.Date) AND p2p."State" = 'Success' THEN checks.Peer END) / COUNT(DISTINCT CASE WHEN date_part('month', peers.Birthday) = date_part('month', checks.Date) AND date_part('day', peers.Birthday) = date_part('day', checks.Date) THEN checks.Peer END), 2) AS successful_checks_percent,
            ROUND(100.0 * COUNT(DISTINCT CASE WHEN date_part('month', peers.Birthday) = date_part('month', checks.Date) AND date_part('day', peers.Birthday) = date_part('day', checks.Date) AND p2p."State" = 'Failure' THEN checks.Peer END) / COUNT(DISTINCT CASE WHEN date_part('month', peers.Birthday) = date_part('month', checks.Date) AND date_part('day', peers.Birthday) = date_part('day', checks.Date) THEN checks.Peer END), 2) AS unsuccessful_checks_percent
        FROM
            p2p
            JOIN checks ON p2p."Check" = checks.ID
            JOIN peers ON peers.Nickname = checks.Peer;
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
        FROM checks c
            JOIN p2p p ON c.id = p."Check"
            JOIN verter v ON c.id = v."Check"
        WHERE c.task = first_task
            AND v."State" = 'Success'
            AND p."State" = 'Success'
        INTERSECT
        SELECT c.peer
        FROM checks c
            JOIN p2p p ON c.id = p."Check"
            JOIN verter v ON c.id = v."Check"
        WHERE c.task = second_task
            AND v."State" = 'Success'
            AND p."State" = 'Success'
        EXCEPT
        SELECT c.peer
        FROM checks c
            JOIN p2p p ON c.id = p."Check"
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
        SELECT Tasks.Title, ParentTask, 0 AS Count FROM Tasks WHERE ParentTask IS NULL
        UNION
        SELECT Tasks.Title, Tasks.ParentTask, preceding_tasks.Count + 1 AS Count
        FROM Tasks
        JOIN preceding_tasks ON preceding_tasks.Title = Tasks.ParentTask
    )
    INSERT INTO temp_tasks_preceding_count (title, count)
    SELECT Tasks.Title, MAX(preceding_tasks.Count) AS Count
    FROM Tasks
    JOIN preceding_tasks ON preceding_tasks.Title = Tasks.Title
    GROUP BY Tasks.Title
    ORDER BY Count DESC;

END;
$$;

CALL proc_tasks_preceding_count();
SELECT * FROM temp_tasks_preceding_count;

DROP TABLE IF EXISTS temp_tasks_preceding_count;

-- 13) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
-- Параметры процедуры: количество идущих подряд успешных проверок N.
-- Временем проверки считать время начала P2P этапа.
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
        FROM checks c1
        JOIN tasks ON c1.task = tasks.title
        JOIN xp ON c1.id = xp."Check"
        JOIN (SELECT "Check", MAX("State") AS "State" FROM verter GROUP BY "Check") v ON c1.id = v."Check"
        WHERE v."State" = 'Success' AND ((xp.xpamount::real / tasks.maxxp::real) * 100) >= 80
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
        SELECT checks.peer, SUM(xp.xpamount)
        FROM checks
        JOIN p2p ON checks.id = p2p."Check"
        JOIN verter ON checks.id = verter."Check"
        JOIN xp ON checks.id = xp."Check"
        WHERE verter."State" = 'Success' AND p2p."State" = 'Success'
        GROUP BY checks.peer
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
    SELECT timetracking.peer
    FROM timetracking
    WHERE "time" < check_time
        AND timetracking."State" = '1'
    GROUP BY timetracking.peer
    HAVING COUNT(timetracking."State") >= n_times;

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
        SELECT DISTINCT timetracking.peer
        FROM timetracking
        WHERE timetracking."State" = '2' AND date >= (CURRENT_DATE - n)
        GROUP BY timetracking.peer
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
                        FROM timetracking
                        JOIN peers ON peers.nickname = timetracking.peer
                        WHERE timetracking."State" = '1'
                            AND (SELECT SUBSTRING(TO_CHAR(timetracking.date, 'yyyy-mm-dd') FROM 6 FOR 2)) =
                                (SELECT SUBSTRING(TO_CHAR(peers.birthday, 'yyyy-mm-dd') FROM 6 FOR 2))
                            AND number = EXTRACT(MONTH FROM timetracking.date)
                    ),
                    0
                )
                FROM peers
                JOIN timetracking ON peers.nickname = timetracking.peer
                WHERE (SELECT SUBSTRING(TO_CHAR(timetracking.date, 'yyyy-mm-dd') FROM 6 FOR 2)) =
                    (SELECT SUBSTRING(TO_CHAR(peers.birthday, 'yyyy-mm-dd') FROM 6 FOR 2))
                AND timetracking."State" = '1'
                AND EXTRACT(HOURS FROM timetracking.time) < 12
                AND number = EXTRACT(MONTH FROM timetracking.date)
            ),
            0
        ) AS earlyentries
    FROM months;

END;
$$ LANGUAGE plpgsql;

CALL pr_early_came_percent();
SELECT * FROM temp_early_came_percent;

DROP TABLE IF EXISTS temp_early_came_percent;













