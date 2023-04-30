-- ================================= DROP ============================

DROP FUNCTION IF EXISTS  add_prp_check() CASCADE;
DROP FUNCTION IF EXISTS  add_verter_check() CASCADE;
DROP FUNCTION IF EXISTS  transferpoint_update_func() CASCADE;
DROP FUNCTION IF EXISTS  xp_update_func() CASCADE;
DROP TRIGGER IF EXISTS transferpoint_update_trigger ON p2p CASCADE;
DROP TRIGGER IF EXISTS xp_update_trigger ON xp CASCADE;


-- ================================= CREATE ============================

--1) Написать процедуру добавления P2P проверки
--Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время.
--Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю).
--Добавить запись в таблицу P2P.
--Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать проверку с незавершенным P2P этапом.

CREATE OR REPLACE  PROCEDURE add_prp_check(checkedpeer_ varchar, checkingpeer_ varchar, task_ varchar, state_ check_status, time_ TIME)
AS $$
    DECLARE new_id INTEGER ;
    BEGIN
        IF (state_ = 'Start') THEN
            insert into Checks (peer, task, date) values (checkedpeer_, task_, CURRENT_DATE);
            new_id = (SELECT currval(pg_get_serial_sequence('Checks','id')));
            insert into p2p ("Check", checkingpeer, "State", time) values (new_id, checkingpeer_, state_, time_);
        ELSE
            new_id = (SELECT "Check"
                      FROM p2p JOIN checks c on p2p."Check" = c.id
                      WHERE checkingpeer = checkingpeer_
                        AND "State" = 'Start'
                        AND peer  = checkedpeer_
                        AND task = task_
                        AND date = CURRENT_DATE);
            IF new_id NOTNULL THEN
                insert into p2p ("Check", checkingpeer, "State", time) values (new_id, checkingpeer_, state_, time_);
            END IF;
        END IF;
    END
$$
LANGUAGE plpgsql;


call  add_prp_check( 'matinish', 'torell', 'C6_s21_matrix', 'Start', '23:47:00');

-- Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время.
-- Добавить запись в таблицу Verter (в качестве проверки указать проверку соответствующего задания
-- с самым поздним (по времени) успешным P2P этапом)

CREATE OR REPLACE  PROCEDURE add_verter_check(checkedpeer_ varchar, task_ varchar, state_ check_status, time_ TIME)
AS $$
    DECLARE check_id INTEGER ;
    BEGIN
        check_id = (SELECT "Check"
                    FROM p2p JOIN checks ON p2p."Check" = checks.id
                    WHERE task = task_ AND "State" = 'Success'
                    ORDER BY date DESC
                    LIMIT 1);
        IF check_id IS NULL THEN
            RAISE EXCEPTION 'Нет подходящей успешной проверки P2P';
        ELSE
            insert into verter ("Check", "State", time) values (check_id, state_, time_);
        END IF;
    END
$$
LANGUAGE plpgsql;


call  add_verter_check( 'cflossie', 'C2_String+', 'Success', '23:47:00');

-- Написать триггер: после добавления записи со статутом "начало" в таблицу P2P, изменить соответствующую
-- запись в таблице TransferredPoints
CREATE OR REPLACE FUNCTION transferpoint_update_func()
    RETURNS trigger AS
$$
    DECLARE checkedpeer1 VARCHAR;
BEGIN
    checkedpeer1 =  (SELECT peer FROM checks WHERE checks.id = new."Check");
    IF new."State" = 'Start' THEN
        UPDATE transferredpoints
        SET pointsamount = pointsamount + 1
        FROM p2p
        WHERE transferredpoints.checkingpeer = new.checkingpeer AND transferredpoints.checkedpeer = checkedpeer1;
        IF NOT FOUND THEN
            BEGIN
            INSERT INTO transferredpoints(checkingpeer, checkedpeer, pointsamount ) values (new.checkingpeer, checkedpeer1, 1);
            END;
        end if;
    END IF;
    RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER transferpoint_update_trigger
    AFTER INSERT
    ON p2p
    FOR EACH ROW
EXECUTE FUNCTION transferpoint_update_func();

-- Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
-- Запись считается корректной, если:
    -- Количество XP не превышает максимальное доступное для проверяемой задачи
    -- Поле Check ссылается на успешную проверку
    -- Если запись не прошла проверку, не добавлять её в таблицу.
CREATE OR REPLACE FUNCTION xp_insert_func()
    RETURNS trigger AS
$$
DECLARE
    max_xp INTEGER;
    check_success_count INTEGER;
BEGIN
    max_xp = (SELECT maxxp
               FROM tasks JOIN checks ON checks.id = new."Check"
               WHERE tasks.title = checks.task);
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