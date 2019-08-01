DROP DATABASE shelter;
CREATE DATABASE shelter;
USE shelter;

CREATE TABLE shelter_manager (
    sm_id INT AUTO_INCREMENT,
    username VARCHAR(20) NOT NULL,
    password VARCHAR(20) NOT NULL,

    PRIMARY KEY (sm_id),
    UNIQUE KEY (username)
);

CREATE TABLE caretaker (
    c_id INT AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,

    PRIMARY KEY (c_id)
);

CREATE TABLE animal (
    a_id INT AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    age INT NOT NULL,
    species VARCHAR(20) NOT NULL,

    PRIMARY KEY (a_id)
);

CREATE TABLE sponsor (
    s_id INT AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    phone BIGINT NOT NULL,

    PRIMARY KEY (s_id)
);

CREATE TABLE responsible_for (
    c_id INT NOT NULL,
    a_id INT NOT NULL,

    FOREIGN KEY (c_id) REFERENCES caretaker (c_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);

CREATE TABLE sponsors (
    s_id INT NOT NULL,
    a_id INT NOT NULL,

    FOREIGN KEY (s_id) REFERENCES sponsor (s_id) ON DELETE CASCADE,
    FOREIGN KEY (a_id) REFERENCES animal (a_id) ON DELETE CASCADE
);

INSERT INTO caretaker (name, surname) VALUES ('sercan', 'ersoy');
INSERT INTO caretaker (name, surname) VALUES ('yasin', 'uygun');
INSERT INTO caretaker (name, surname) VALUES ('emirhan', 'cetin');
INSERT INTO caretaker (name, surname) VALUES ('altay', 'ince');
INSERT INTO caretaker (name, surname) VALUES ('ali', 'soydan');
INSERT INTO caretaker (name, surname) VALUES ('hazo', 'demir');
INSERT INTO caretaker (name, surname) VALUES ('gurkan', 'celik');
INSERT INTO caretaker (name, surname) VALUES ('oguzhan', 'bolukbas');

INSERT INTO animal (name, age, species) VALUES ('tekir', 2, 'cat');
INSERT INTO animal (name, age, species) VALUES ('karabas', 2, 'dog');
INSERT INTO animal (name, age, species) VALUES ('miskin', 1, 'cat');
INSERT INTO animal (name, age, species) VALUES ('alac', 3, 'cow');
INSERT INTO animal (name, age, species) VALUES ('duman', 2, 'cat');
INSERT INTO animal (name, age, species) VALUES ('ati', 2, 'dog');
INSERT INTO animal (name, age, species) VALUES ('karamel', 1, 'cat');
INSERT INTO animal (name, age, species) VALUES ('milka', 3, 'cow');

INSERT INTO responsible_for (c_id, a_id) VALUES (1, 1);
INSERT INTO responsible_for (c_id, a_id) VALUES (1, 2);
INSERT INTO responsible_for (c_id, a_id) VALUES (2, 3);
INSERT INTO responsible_for (c_id, a_id) VALUES (4, 4);

