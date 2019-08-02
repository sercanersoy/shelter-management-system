DROP DATABASE shelter;
CREATE DATABASE shelter;
USE shelter;

###### TABLE DEFINITIONS ######
CREATE TABLE shelter_manager
(
    sm_id    INT AUTO_INCREMENT,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(20) NOT NULL,

    PRIMARY KEY (sm_id),
    UNIQUE KEY (username)
);

CREATE TABLE caretaker
(
    c_id    INT AUTO_INCREMENT,
    name    VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,

    PRIMARY KEY (c_id)
);

CREATE TABLE animal
(
    a_id    INT AUTO_INCREMENT,
    name    VARCHAR(20) NOT NULL,
    age     INT         NOT NULL,
    species VARCHAR(20) NOT NULL,

    PRIMARY KEY (a_id),
    UNIQUE KEY (name)
);

CREATE TABLE sponsor
(
    s_id    INT AUTO_INCREMENT,
    name    VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    phone   BIGINT      NOT NULL,

    PRIMARY KEY (s_id),
    UNIQUE KEY (phone)
);
###### TABLE DEFINITIONS ######

###### RELATION DEFINITIONS ######
CREATE TABLE responsible_for
(
    c_id INT,
    a_id INT,

    FOREIGN KEY (c_id) REFERENCES caretaker (c_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);

CREATE TABLE sponsors
(
    s_id INT,
    a_id INT,

    FOREIGN KEY (s_id) REFERENCES sponsor (s_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);
###### RELATION DEFINITIONS ######

###### TRIGGERS ######
/*DELIMITER //
CREATE TRIGGER todo
    BEFORE INSERT ON responsible_for
    FOR EACH ROW
    BEGIN

    END //
DELIMITER ;*/

/*DELIMITER //
CREATE TRIGGER todo
    AFTER INSERT
    ON animal
    FOR EACH ROW
BEGIN
    INSERT INTO responsible_for (c_id, a_id) VALUES ((SELECT c_id FROM (SELECT c_id, COUNT(a_id) AS count FROM (SELECT caretaker.c_id, responsible_for.a_id FROM caretaker LEFT JOIN responsible_for ON caretaker.c_id = responsible_for.c_id) AS with_null GROUP BY c_id) AS counts WHERE count = (SELECT MIN(count) FROM counts)), NEW.a_id);
END //
DELIMITER ;*/

###### TRIGGERS ######

###### PROCEDURES ######
/*
DELIMITER //
CREATE PROCEDURE country_hos
 (IN con CHAR (20))
BEGIN
  SELECT Name, HeadOfState FROM Country
  WHERE Continent = con;
END //
DELIMITER ;
*/
###### PROCEDURES ######

###### INSERTIONS ######
INSERT INTO caretaker (name, surname)
VALUES ('sercan', 'ersoy');
INSERT INTO caretaker (name, surname)
VALUES ('yasin', 'uygun');
INSERT INTO caretaker (name, surname)
VALUES ('emirhan', 'cetin');
INSERT INTO caretaker (name, surname)
VALUES ('altay', 'ince');
INSERT INTO caretaker (name, surname)
VALUES ('ali', 'soydan');
INSERT INTO caretaker (name, surname)
VALUES ('hazo', 'demir');
INSERT INTO caretaker (name, surname)
VALUES ('gurkan', 'celik');
INSERT INTO caretaker (name, surname)
VALUES ('oguzhan', 'bolukbas');

INSERT INTO animal (name, age, species)
VALUES ('tekir', 2, 'cat');
INSERT INTO animal (name, age, species)
VALUES ('karabas', 2, 'dog');
INSERT INTO animal (name, age, species)
VALUES ('miskin', 1, 'cat');
INSERT INTO animal (name, age, species)
VALUES ('alac', 3, 'cow');
INSERT INTO animal (name, age, species)
VALUES ('duman', 2, 'cat');
INSERT INTO animal (name, age, species)
VALUES ('ati', 2, 'dog');
INSERT INTO animal (name, age, species)
VALUES ('karamel', 1, 'cat');
INSERT INTO animal (name, age, species)
VALUES ('milka', 3, 'cow');

INSERT INTO responsible_for (c_id, a_id) VALUES (1,1);
INSERT INTO responsible_for (c_id, a_id) VALUES (1,2);

(SELECT c_id, COUNT(a_id) AS animal_count FROM (SELECT c.c_id, r.a_id FROM caretaker c LEFT JOIN responsible_for r ON c.c_id = r.c_id) AS with_null GROUP BY c_id);
SELECT c_id FROM (SELECT c_id, COUNT(a_id) AS animal_count FROM (SELECT caretaker.c_id, responsible_for.a_id FROM caretaker LEFT JOIN responsible_for ON caretaker.c_id = responsible_for.c_id) AS with_null GROUP BY c_id) AS counts HAVING counts.animal_count = (SELECT MIN(animal_count) FROM counts);/*(SELECT MIN(counts.animal_count) FROM counts)*/;


###### INSERTIONS ######
