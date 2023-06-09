-----------------------------------------Create Database----------------------------------------
CREATE DATABASE librarydbms;
USE librarydbms;
SET GLOBAL event_scheduler = ON;

-----------------------------------------Tables----------------------------------------
--administrator(admin_id, login_id, passwd, first_name, last_name, sex, birth_date)
CREATE TABLE administrator(
    admin_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    login_id VARCHAR(50) NOT NULL,
    passwd VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    sex ENUM('Male', 'Female', 'Other') NOT NULL,
    birth_date DATE NOT NULL,
    PRIMARY KEY (admin_id),
    UNIQUE (login_id),
    CHECK (birth_date < '2000-01-01')
);

--school(school_id, school_name, city, phone_number, email, addrss, admin_id)
CREATE TABLE school(
    school_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    school_name VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    addrss VARCHAR(50) NOT NULL,
    admin_id INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (school_id),
    CONSTRAINT fk_school_administrator
        FOREIGN KEY (admin_id) REFERENCES administrator (admin_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    UNIQUE (school_name),
    UNIQUE (phone_number),
    UNIQUE (addrss),
    UNIQUE (email)
);

--school_admin(scadmin_id, login_id, passwd, first_name, last_name, sex, birth_date, scadmin_status, school_id, admin_id)
CREATE TABLE school_admin(
    scadmin_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    login_id VARCHAR(50) NOT NULL,
    passwd VARCHAR(100) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    sex ENUM('Male', 'Female', 'Other') NOT NULL,
    birth_date DATE NOT NULL,
    school_id INT UNSIGNED NOT NULL,
    admin_id INT UNSIGNED DEFAULT NULL,
    scadmin_status ENUM('Declined', 'Waiting', 'Approved') NOT NULL DEFAULT 'Waiting',
    PRIMARY KEY (scadmin_id),
    CONSTRAINT fk_school_admin_school
        FOREIGN KEY (school_id) REFERENCES school(school_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_school_admin_administrator
        FOREIGN KEY (admin_id) REFERENCES administrator(admin_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE, 
    UNIQUE (login_id),
    CHECK (birth_date < '2000-01-01')
);

--user(user_id, login_id, passwd, first_name, last_name, birth_date, school_name, job, books_borrowed, user_status)
CREATE TABLE user(
    user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    login_id VARCHAR(50) NOT NULL,
    passwd VARCHAR(100) NOT NULL, 
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    school_id INT UNSIGNED NOT NULL,
    sex ENUM('Male', 'Female', 'Other') NOT NULL,
    job ENUM('Student', 'Teacher') NOT NULL,
    books_borrowed INT UNSIGNED NOT NULL DEFAULT 0,
    user_status ENUM('Waiting', 'Approved', 'Declined') NOT NULL DEFAULT 'Waiting',
    PRIMARY KEY (user_id),
    CONSTRAINT fk_user_school 
        FOREIGN KEY (school_id) REFERENCES school(school_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    UNIQUE (login_id),
    CHECK ((birth_date < '2018-01-01' AND job = 'Student') OR (birth_date < '2000-01-01' AND job = 'Teacher'))
);


--book(ISBN, book_title, publisher, no_pages, summary, available, img, sprache, school_id, scadmin_id)
CREATE TABLE book(
    ISBN VARCHAR(50) NOT NULL,
    school_id INT UNSIGNED NOT NULL,
    book_title VARCHAR(100) NOT NULL,
    publisher VARCHAR(50) NOT NULL,
    no_pages INT UNSIGNED NOT NULL,
    summary TEXT NOT NULL,
    available INT UNSIGNED NOT NULL DEFAULT 1,
    img LONGBLOB, 
    sprache VARCHAR(50) DEFAULT 'English',
    scadmin_id INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (ISBN, school_id),
    CONSTRAINT fk_book_school
        FOREIGN KEY (school_id) REFERENCES school(school_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_book_administrator 
        FOREIGN KEY (scadmin_id) REFERENCES school_admin(scadmin_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

--review(review_id, ISBN, user_id, review_date, txt, likert, review_status)
CREATE TABLE review(
    review_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    ISBN VARCHAR(50) NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    review_date DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    txt TEXT NOT NULL,
    likert VARCHAR(50) DEFAULT NULL,
    review_status ENUM('Waiting', 'Approved', 'Declined') NOT NULL DEFAULT 'Waiting',
    school_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (review_id),
    CONSTRAINT fk_review_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_school 
        FOREIGN KEY (school_id) REFERENCES school(school_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

--author(author_id, first_name, last_name, ISBN)
CREATE TABLE author(
    author_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ISBN VARCHAR(50) NOT NULL,
    PRIMARY KEY (author_id), 
    CONSTRAINT fk_author_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

--category(category_id, category, ISBN)
CREATE TABLE category(
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category VARCHAR(50) NOT NULL,
    ISBN VARCHAR(50) NOT NULL,
    PRIMARY KEY (category_id),
    CONSTRAINT fk_category_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

--keyword(keyword_id, keyword, ISBN)
CREATE TABLE keywords(
    keyword_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    keyword VARCHAR(20) NOT NULL,
    ISBN VARCHAR(50) NOT NULL,
    PRIMARY KEY (keyword_id),
    CONSTRAINT fk_keywords_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

--reservation(reservation_id, ISBN, user_id, reservation_date, reservation_status)
CREATE TABLE reservation(
    reservation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    ISBN VARCHAR(50) NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    reservation_date DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reservation_to_date DATE NOT NULL,
    reservation_status ENUM('Waiting Queue', 'Waiting', 'Declined', 'Approved') NOT NULL DEFAULT 'Waiting',
    scadmin_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_reservation_user
        FOREIGN KEY (user_id) REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_reservation_scadmin 
        FOREIGN KEY (scadmin_id) REFERENCES school_admin(scadmin_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

--borrowing(borrowing_id, ISBN, user_id, borrowing_date, borrowing_status, scadmin_id)
CREATE TABLE borrowing(
    borrowing_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    ISBN VARCHAR(50) NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    borrowing_date DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    borrowing_status ENUM('Waiting', 'Approved', 'Declined', 'Completed') DEFAULT 'Waiting',
    scadmin_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (borrowing_id),
    CONSTRAINT fk_borrowing_book
        FOREIGN KEY (ISBN) REFERENCES book(ISBN) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_borrowing_user
        FOREIGN KEY (user_id) REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_borrowing_scadmin 
        FOREIGN KEY (scadmin_id) REFERENCES school_admin(scadmin_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-----------------------------------------Indexes-------------------------------------------------------
--Gonna add some indexes here
CREATE INDEX idx_author ON author (first_name, last_name, ISBN);
CREATE INDEX idx_category ON category (category, ISBN);
CREATE INDEX idx_user ON user (user_id, first_name, last_name, job, user_status, books_borrowed, login_id);
CREATE INDEX idx_school ON school (school_id, school_name);
CREATE INDEX idx_borrowing ON borrowing (borrowing_id, ISBN, user_id, borrowing_date, borrowing_status, scadmin_id);
CREATE INDEX idx_book ON book (ISBN, book_title, school_id, scadmin_id);
CREATE INDEX idx_school_admin ON school_admin (scadmin_id, first_name, last_name, login_id, school_id);
CREATE INDEX idx_review ON review (review_id, user_id, review_status, ISBN);
CREATE INDEX idx_reservation ON reservation(reservation_id, ISBN, user_id, reservation_date, reservation_to_date, reservation_status);
------------------------------------Trigger---------------------------------------------
DELIMITER //
CREATE TRIGGER borrowing_state AFTER INSERT ON borrowing FOR EACH ROW
BEGIN
    IF NEW.borrowing_status = 'Approved' THEN 
        UPDATE user 
        SET books_borrowed = books_borrowed + 1
        WHERE user.user_id = NEW.user_id;

        UPDATE book 
        SET available = available - 1
        WHERE (book.ISBN = NEW.ISBN AND school_id = (SELECT school_id FROM school WHERE school_id = NEW.scadmin_id));
    END IF;
END
//
DELIMITER ;

--Erasing every day the too delayed reservations
DELIMITER //
CREATE EVENT too_delayed
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM librarydbms.reservation 
    WHERE (DATEDIFF(CAST(CURRENT_TIMESTAMP AS DATE), CAST(reservation_date AS DATETIME)) >= 7 AND reservation_status = 'Waiting');
    DELETE FROM librarydbms.borrowing
    WHERE (DATEDIFF(CAST(CURRENT_TIMESTAMP AS DATE), CAST(borrowing_date AS DATETIME)) >= 7 AND borrowing_status = 'Waiting');
END
//
DELIMITER ;

DELIMITER //
CREATE EVENT reservation_made_borrowing 
ON SCHEDULE EVERY 1 MINUTE 
DO 
BEGIN
    SET @flag = NULL;

    SELECT reservation_id INTO @flag
    FROM reservation
    WHERE (reservation_status = 'Approved' AND reservation_to_date = CAST(CURRENT_TIMESTAMP AS DATE));

    IF (@flag IS NOT NULL) THEN 
        INSERT INTO borrowing (ISBN, user_id, borrowing_date, borrowing_status, scadmin_id)
        SELECT ISBN, user_id, reservation_to_date, reservation_status, scadmin_id
        FROM reservation
        WHERE (reservation_status = 'Approved' AND reservation_to_date = CAST(CURRENT_TIMESTAMP AS DATE));

        DELETE FROM reservation
        WHERE reservation_id = @flag;
    END IF;
END
//
DELIMITER ;
------------------------Extras that occured while builidng the app--------------------------

