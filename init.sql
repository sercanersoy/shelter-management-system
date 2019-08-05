DROP DATABASE IF EXISTS shelter;
CREATE DATABASE shelter;
USE shelter;

###### TABLE DEFINITIONS ######
CREATE TABLE shelter_manager
(
    sm_id    INT AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,

    PRIMARY KEY (sm_id),
    UNIQUE KEY (username)
);

CREATE TABLE caretaker
(
    c_id    INT AUTO_INCREMENT,
    name    VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,

    PRIMARY KEY (c_id),
    UNIQUE KEY (name, surname)
);

CREATE TABLE animal
(
    a_id    INT AUTO_INCREMENT,
    name    VARCHAR(255) NOT NULL,
    age     INT         NOT NULL,
    species VARCHAR(255) NOT NULL,

    PRIMARY KEY (a_id),
    UNIQUE KEY (name)
);

CREATE TABLE sponsor
(
    s_id    INT AUTO_INCREMENT,
    name    VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    phone   VARCHAR(255) NOT NULL,

    PRIMARY KEY (s_id),
    UNIQUE KEY (name, surname)
);

###### RELATION DEFINITIONS ######
CREATE TABLE responsible_for
(
    c_id INT NOT NULL,
    a_id INT NOT NULL,

    FOREIGN KEY (c_id) REFERENCES caretaker (c_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);

CREATE TABLE sponsors
(
    s_id INT NOT NULL,
    a_id INT NOT NULL,

    FOREIGN KEY (s_id) REFERENCES sponsor (s_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);

###### TRIGGERS ######
DELIMITER //
CREATE TRIGGER after_animal_insertion
    AFTER INSERT
    ON animal
    FOR EACH ROW
BEGIN
    DECLARE caretaker_id INT;
    SELECT c_id
    INTO caretaker_id
    FROM (SELECT c_id, COUNT(a_id) AS animal_count
          FROM (SELECT c.c_id, r.a_id
                FROM caretaker c
                         LEFT JOIN responsible_for r ON c.c_id = r.c_id) AS with_null
          GROUP BY c_id
          ORDER BY animal_count LIMIT 1) AS min_animal_count;
    IF caretaker_id IS NOT NULL THEN
        INSERT INTO responsible_for (c_id, a_id) VALUES (caretaker_id, NEW.a_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Shelter does not have any caretakers, add a caretaker before adding an animal.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_animal_deletion
    BEFORE DELETE
    ON animal
    FOR EACH ROW
BEGIN
    DECLARE sponsor_id INT;
    DECLARE animal_id INT;
    SELECT s.s_id
    INTO sponsor_id
    FROM animal a
             LEFT JOIN sponsors s ON a.a_id = s.a_id
    WHERE a.a_id = OLD.a_id;
    IF sponsor_id IS NOT NULL THEN
        SELECT a.a_id INTO animal_id FROM animal a LEFT JOIN sponsors s ON a.a_id = s.a_id WHERE s.s_id IS NULL ORDER BY a.age DESC LIMIT 1;
        IF animal_id IS NOT NULL THEN
            INSERT INTO sponsors (s_id, a_id)
                VALUES (sponsor_id, animal_id);
        END IF;
    END IF;
END //
DELIMITER ;

###### PROCEDURES ######
################## MANIPULATE SHELTER MANAGERS ##################
DELIMITER //
CREATE PROCEDURE add_shelter_manager(IN _username VARCHAR(255), IN _password VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM shelter_manager WHERE username = _username) THEN
        SELECT 'Shelter manager already exists.';
    ELSE
        INSERT INTO shelter_manager (username, password) VALUES (_username, _password);
        SELECT 'Shelter manager added successfully.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_shelter_manager(IN old_username VARCHAR(255), IN new_username VARCHAR(255), IN new_password VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM shelter_manager WHERE username = old_username) THEN
        IF (SELECT COUNT(*) FROM shelter_manager WHERE username = new_username) THEN
            SELECT 'Shelter manager with new username already exists.';
        ELSE
            UPDATE shelter_manager SET username = new_username, password = new_password WHERE username = old_username;
            SELECT 'Shelter manager updated successfully.';
        END IF;
    ELSE
        SELECT 'Shelter manager does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE delete_shelter_manager(IN _username VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM shelter_manager WHERE username = _username) THEN
        DELETE FROM shelter_manager WHERE username = _username;
        SELECT 'Shelter manager deleted successfully.';
    ELSE
        SELECT 'Shelter manager does not exist.';
    END IF;
END //
DELIMITER ;

################## MANIPULATE CARETAKERS ##################
DELIMITER //
CREATE PROCEDURE add_caretaker(IN _name VARCHAR(255), IN _surname VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM caretaker WHERE name = _name AND surname = _surname) THEN
        SELECT 'Caretaker already exist.';
    ELSE
        INSERT INTO caretaker (name, surname) VALUES (_name, _surname);
        SELECT 'Caretaker added successfully.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_caretaker(IN old_name VARCHAR(255), IN old_surname VARCHAR(255), IN new_name VARCHAR(255), IN new_surname VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM caretaker WHERE name = old_name AND surname = old_surname) THEN
        IF (SELECT COUNT(*) FROM caretaker WHERE name = new_name AND surname = new_surname) THEN
            SELECT 'Caretaker with new name and surname already exists.';
        ELSE
            UPDATE caretaker SET name = new_name, surname = new_surname WHERE name = old_name AND surname = old_surname;
            SELECT 'Caretaker updated successfully';
        END IF;
    ELSE
        SELECT 'Caretaker does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE delete_caretaker(IN _name VARCHAR(255), IN _surname VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM caretaker WHERE name = _name AND surname = _surname) THEN
        DELETE FROM caretaker WHERE name = _name AND surname = _surname;
        SELECT 'Caretaker deleted successfully.';
    ELSE
        SELECT 'Caretaker does not exist.';
    END IF;
END //
DELIMITER ;

################## MANIPULATE ANIMALS ##################
DELIMITER //
CREATE PROCEDURE add_animal(IN _name VARCHAR(255), IN _age INT, IN _species VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM animal WHERE name = _name) THEN
        SELECT 'Animal already exist.';
    ELSE
        INSERT INTO animal (name, age, species) VALUES (_name, _age, _species);
        SELECT 'Animal added successfully.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_animal(IN old_name VARCHAR(255), IN new_name VARCHAR(255), IN new_age INT, IN new_species VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM animal WHERE name = old_name) THEN
        IF (SELECT COUNT(*) FROM animal WHERE name = new_name) THEN
            SELECT 'Animal with new name already exists.';
        ELSE
            UPDATE animal SET name = new_name, age = new_age, species = new_species WHERE name = old_name;
            SELECT 'Animal updated successfully';
        END IF;
    ELSE
        SELECT 'Animal does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE assign_sponsor(IN _name VARCHAR(255), IN sponsor_name VARCHAR(255), IN sponsor_surname VARCHAR(255))
BEGIN
    DECLARE animal_id INT;
    IF (SELECT COUNT(*) FROM animal WHERE name = _name) THEN
        IF (SELECT COUNT(*) FROM sponsor WHERE name = sponsor_name AND surname = sponsor_surname) THEN
            SELECT a_id INTO animal_id FROM animal WHERE name = _name;
            IF (SELECT COUNT(*) FROM sponsors WHERE a_id = animal_id) THEN
                DELETE FROM sponsors WHERE a_id = animal_id;
            END IF;
            INSERT INTO sponsors (s_id, a_id) VALUES((SELECT s_id FROM sponsor WHERE name = sponsor_name AND surname = sponsor_surname), animal_id);
            SELECT 'Sponsor assigned to the animal successfully.';
        ELSE
            SELECT 'Sponsor does not exist.';
        END IF;
    ELSE
        SELECT 'Animal does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE unassign_sponsor(IN _name VARCHAR(255))
BEGIN
    DECLARE animal_id INT;
    IF (SELECT COUNT(*) FROM animal WHERE name = _name) THEN
        SELECT a_id INTO animal_id FROM animal WHERE name = _name;
        IF (SELECT COUNT(*) FROM sponsors WHERE a_id = animal_id) THEN
            DELETE FROM sponsors WHERE a_id = animal_id;
            SELECT 'Sponsor unassigned from the animal successfully.';
        ELSE
            SELECT 'Animal does not have a sponsor.';
        END IF;
    ELSE
        SELECT 'Animal does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE change_caretaker(IN _name VARCHAR(255), IN caretaker_name VARCHAR(255), IN caretaker_surname VARCHAR(255))
BEGIN
    DECLARE animal_id INT;
    IF (SELECT COUNT(*) FROM animal WHERE name = _name) THEN
        IF (SELECT COUNT(*) FROM caretaker WHERE name = caretaker_name AND surname = caretaker_surname) THEN
            SELECT a_id INTO animal_id FROM animal WHERE name = _name;
            DELETE FROM responsible_for WHERE a_id = animal_id;
            INSERT INTO responsible_for (c_id, a_id) VALUES((SELECT c_id FROM caretaker WHERE name = caretaker_name AND surname = caretaker_surname), animal_id);
            SELECT 'Caretaker changed successfully.';
        ELSE
            SELECT 'Caretaker does not exist.';
        END IF;
    ELSE
        SELECT 'Animal does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE delete_animal(IN _name VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM animal WHERE name = _name) THEN
        DELETE FROM animal WHERE name = _name;
        SELECT 'Animal deleted successfully.';
    ELSE
        SELECT 'Animal does not exist.';
    END IF;
END //
DELIMITER ;

################## MANIPULATE SPONSORS ##################
DELIMITER //
CREATE PROCEDURE add_sponsor(IN _name VARCHAR(255), IN _surname VARCHAR(255), IN _phone VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM sponsor WHERE name = _name AND surname = _surname) THEN
        SELECT 'Sponsor already exist.';
    ELSE
        INSERT INTO sponsor (name, surname, phone) VALUES (_name, _surname, _phone);
        SELECT 'Sponsor added successfully.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_sponsor(IN old_name VARCHAR(255), IN old_surname VARCHAR(255), IN new_name VARCHAR(255), IN new_surname VARCHAR(255), IN new_phone VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM sponsor WHERE name = old_name AND surname = old_surname) THEN
        IF (SELECT COUNT(*) FROM sponsor WHERE name = new_name AND surname = new_surname) THEN
            SELECT 'Sponsor with new name and surname already exists.';
        ELSE
            UPDATE sponsor SET name = new_name, surname = new_surname, phone = new_phone WHERE name = old_name AND surname = old_surname;
            SELECT 'Sponsor updated successfully';
        END IF;
    ELSE
        SELECT 'Sponsor does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE delete_sponsor(IN _name VARCHAR(255), IN _surname VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM sponsor WHERE name = _name AND surname = _surname) THEN
        DELETE FROM sponsor WHERE name = _name AND surname = _surname;
        SELECT 'Sponsor deleted successfully.';
    ELSE
        SELECT 'Sponsor does not exist.';
    END IF;
END //
DELIMITER ;

################## VIEWS AND OTHERS ##################
#### ALL ####
DELIMITER //
CREATE PROCEDURE view_shelter_managers()
BEGIN
    SELECT username FROM shelter_manager;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_caretakers()
BEGIN
    SELECT name, surname FROM caretaker;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_animals()
BEGIN
    SELECT a.name, a.age, a.species, c.name, c.surname, s.name, s.surname FROM animal a NATURAL JOIN responsible_for r JOIN caretaker c ON r.c_id = c.c_id LEFT JOIN sponsors ss ON a.a_id = ss.a_id LEFT JOIN sponsor s ON ss.s_id = s.s_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_sponsors()
BEGIN
    SELECT name, surname, phone FROM sponsor;
END //
DELIMITER ;

#### SPECIFIC ####
DELIMITER //
CREATE PROCEDURE view_animals_of_caretaker(IN _name VARCHAR(255), IN _surname VARCHAR(255))
BEGIN
    SELECT name, age, species FROM animal NATURAL JOIN (SELECT a_id FROM responsible_for WHERE c_id = (SELECT c_id FROM caretaker WHERE name = _name AND surname = _surname)) AS animal_ids_of_caretaker;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_animals_of_sponsor(IN _name VARCHAR(255), IN _surname VARCHAR(255))
BEGIN
    SELECT name, age, species FROM animal NATURAL JOIN (SELECT a_id FROM sponsors WHERE s_id = (SELECT s_id FROM sponsor WHERE name = _name AND surname = _surname)) AS animal_ids_of_sponsor;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_animals_of_species(IN _species VARCHAR(255))
BEGIN
    SELECT name, age, species FROM animal WHERE species = _species;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE view_animals_without_sponsor()
BEGIN
    SELECT a.name, a.age, a.species FROM animal a LEFT JOIN sponsors s ON a.a_id = s.a_id WHERE s.s_id IS NULL;
END //
DELIMITER ;

#### OTHER ####
DELIMITER //
CREATE PROCEDURE login(IN _username VARCHAR(255), IN _password VARCHAR(255))
BEGIN
    IF (SELECT COUNT(*) FROM shelter_manager WHERE username = _username) THEN
        IF !(SELECT COUNT(*) FROM shelter_manager WHERE username = _username AND password = _password) THEN
            SELECT 'Invalid password.';
        END IF;
    ELSE
        SELECT 'User does not exist.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE rank_caretakers()
BEGIN
    SELECT c.name, c.surname, COUNT(r.a_id) AS `rank` FROM caretaker c LEFT JOIN responsible_for r ON c.c_id = r.c_id GROUP BY c.c_id ORDER BY `rank` DESC;
END //
DELIMITER ;

###### TESTS ######

CALL add_shelter_manager('john', 'john1234');
CALL add_shelter_manager('jane', '123jane');

CALL add_caretaker('Diana', 'Becker');
CALL add_caretaker('Simon', 'Armstrong');

CALL add_sponsor('Joseph', 'Ward', '(889) 410-2416');
CALL add_sponsor('Monica', 'Rios', '(346) 530-0179');
CALL add_sponsor('Norma', 'George', '(871) 544-1774');

CALL add_animal('Max', 10, 'Golden Retriever');
CALL add_animal('Lucy', 6, 'Rottweiler');
CALL add_animal('Lola', 1, 'Golden Retriever');
CALL add_animal('Charlie', 4, 'Bulldog');
CALL add_animal('Daisy', 3, 'German Shepherd');

CALL assign_sponsor('Lucy', 'Monica', 'Rios');
CALL assign_sponsor('Lola', 'Norma', 'George');
CALL assign_sponsor('Charlie', 'Monica', 'Rios');
CALL assign_sponsor('Daisy', 'Joseph', 'Ward');

CALL change_caretaker('Max', 'Diana', 'Becker');
CALL change_caretaker('Lucy', 'Diana', 'Becker');
CALL change_caretaker('Lola', 'Simon', 'Armstrong');
CALL change_caretaker('Charlie', 'Simon', 'Armstrong');
CALL change_caretaker('Daisy', 'Diana', 'Becker');

/*INSERT INTO shelter_manager (username, password)
VALUES ('hanife', 'ersoy');
INSERT INTO shelter_manager (username, password)
VALUES ('vezni', 'ersoy');

CALL add_caretaker('sercan', 'ersoy');
CALL add_caretaker('yasin', 'uygun');
CALL add_caretaker('emirhan', 'cetin');
CALL add_caretaker('altay', 'ince');
CALL add_caretaker('muharrem', 'ince');
CALL add_caretaker('ali', 'soydan');
CALL update_caretaker('ali', 'soydan', 'hazo', 'demir');
CALL delete_caretaker('hazo', 'demir');
INSERT INTO caretaker (name, surname)
VALUES ('hazo', 'demir');
INSERT INTO caretaker (name, surname)
VALUES ('gurkan', 'celik');
INSERT INTO caretaker (name, surname)
VALUES ('oguzhan', 'bolukbas');

CALL add_animal('tekir', 8, 'cat');
CALL add_animal('karabas', 2, 'dog');
CALL add_animal('miskin', 1, 'cat');
CALL add_animal('alac', 10, 'cow');
CALL add_animal('duman', 2, 'cat');
CALL add_animal('ati', 2, 'dog');
CALL add_animal('karamel', 1, 'cat');
CALL add_animal('milka', 3, 'cow');
CALL add_animal('koko', 5, 'gorilla');
CALL add_animal('tekin', 8, 'cat');
CALL add_animal('akbas', 2, 'dog');
CALL add_animal('sungur', 1, 'cat');
CALL add_animal('kalic', 4, 'cow');
CALL add_animal('mist', 2, 'cat');
CALL add_animal('tako', 2, 'dog');
CALL delete_animal('koko');

CALL add_sponsor('veysi', 'ertekin', 5416713757);
CALL add_sponsor('hatice', 'ozdemir', 5316313131);
CALL add_sponsor('alper', 'simsek', 5466464646);
CALL add_sponsor('cansu', 'ozbilek', 5568767676);
CALL update_sponsor('cansu', 'ozbilek', 'tugce', 'ates', 1231231232);
CALL add_sponsor('cansu', 'ozbilek', 5568767676);
CALL delete_sponsor('tugce', 'ates');

INSERT INTO sponsors (s_id, a_id)
VALUES (1, 1);
INSERT INTO sponsors (s_id, a_id)
VALUES (2, 3);
INSERT INTO sponsors (s_id, a_id)
VALUES (2, 2);
INSERT INTO sponsors (s_id, a_id)
VALUES (3, 4);

CALL add_shelter_manager('cengiz', 'can');
CALL update_shelter_manager('cengiz', 'cemal', 'can');
CALL delete_shelter_manager('cemal');

CALL add_caretaker('kemal', 'sertkaya');
CALL add_animal('ciko', 1, 'cat');
CALL add_animal('gulizar', 3, 'cow');

CALL view_animals();
CALL view_caretakers();
CALL view_shelter_managers();
CALL view_sponsors();

*/