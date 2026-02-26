
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(250) NOT NULL,
    email VARCHAR(150) NOT NULL,
    identification VARCHAR(10) NOT NULL UNIQUE,
    gender VARCHAR(10) CHECK(gender IN ('M', 'F', 'Other')),
    career VARCHAR(50) NOT NULL,
    birth_day DATE NOT NULL,
    entry_date DATE	NOT NULL
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(250) NOT NULL,
    email_inst VARCHAR(150) NOT NULL,
    academic_dept VARCHAR(100) NOT NULL,
    years_exp INT NOT NULL CHECK(years_exp >= 0)
);
CREATE TABLE courses (
    course_id  INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(250) NOT NULL,
    code VARCHAR(150) NOT NULL UNIQUE,
    credits INT NOT NULL CHECK(credits > 0),
    semester INT NOT NULL CHECK(semester BETWEEN 1 AND 10), 
    teacher_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);


CREATE TABLE inscriptions (
    inscription_id  INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    inscription_date DATE NOT NULL,
    final_grade DECIMAL(5,2) CHECK(final_grade BETWEEN 0 AND 10),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

# DATA INSERT
-- first teachers cause courses depends on it.
INSERT INTO teachers (full_name, email_inst, academic_dept, years_exp) VALUES
('Carlos Mendoza', 'c.mendoza@uni.edu', 'Ingeniería de Sistemas', 8),
('Laura Rodríguez', 'l.rodriguez@uni.edu', 'Matemáticas', 3),
('Pedro Jiménez', 'p.jimenez@uni.edu', 'Ciencias Básicas', 12);

INSERT INTO students (full_name, email, identification, gender, career, birth_day, entry_date) VALUES
('Ana García', 'ana.garcia@email.com',    '1001234567', 'F', 'Ingeniería', '2000-03-15', '2022-01-10'),
('Luis Pérez', 'luis.perez@email.com',    '1009876543', 'M', 'Medicina',   '1999-07-22', '2021-01-10'),
('María Torres', 'maria.torres@email.com',  '1002345678', 'F', 'Derecho',    '2001-11-05', '2023-01-10'),
('Jorge Ramírez', 'jorge.ramirez@email.com', '1003456789', 'M', 'Ingeniería', '2000-06-18', '2022-01-10'),
('Sofía Castillo', 'sofia.castillo@email.com','1004567890', 'F', 'Medicina',   '2001-02-28', '2023-01-10');

INSERT INTO courses (name, code, credits, semester, teacher_id) VALUES
('Cálculo I', 'MAT101', 4, 1, 2),
('Programación Básica', 'SIS101', 3, 1, 1),
('Álgebra Lineal', 'MAT201', 4, 2, 2),
('Bases de Datos', 'SIS301', 3, 3, 1);

INSERT INTO inscriptions (student_id, course_id, inscription_date, final_grade) VALUES
(1, 1, '2022-01-15', 8.5),
(1, 2, '2022-01-15', 9.0),   
(2, 1, '2021-01-15', 7.0), 
(2, 3, '2021-01-15', 6.5),   
(3, 2, '2023-01-15', 9.5),   
(4, 3, '2022-01-15', 8.0),   
(4, 4, '2022-01-15', 7.5),   
(5, 4, '2023-01-15', 9.0);   

#3). 1:
SELECT s.full_name AS "student",
c.name AS "courses",
i.inscription_date AS "inscription",
i.final_grade AS "calification"
FROM students s
JOIN inscriptions i ON s.student_id = i.student_id
JOIN courses c ON i.course_id = c.course_id 
ORDER BY s.full_name;

#3). 2:
SELECT c.name AS course,
t.full_name AS teacher,
t.years_exp AS years_experience
FROM courses c 
JOIN teachers t ON c.teacher_id = t.teacher_id
WHERE t.years_exp > 5;

#3). 3:
SELECT c.name AS course, AVG(i.final_grade) AS avg_calification
FROM courses c 
JOIN inscriptions i ON c.course_id = i.course_id
GROUP BY c.course_id, c.name
ORDER BY avg_calification DESC;

#3). 4:
SELECT s.full_name AS student, COUNT(i.course_id) AS enrolled_course
FROM students s
JOIN inscriptions i ON s.student_id = i.student_id
GROUP BY s.student_id, s.full_name  
HAVING COUNT(i.course_id) > 1;

#3). 5:
ALTER TABLE students 
ADD COLUMN academic_status VARCHAR(50) DEFAULT 'active' AFTER career;
SELECT * FROM students; 

#3). 6:
SELECT * FROM teachers;
DELETE FROM teachers WHERE teacher_id = 3;

ALTER TABLE courses DROP FOREIGN KEY courses_ibfk_1;
SELECT * FROM teachers;  
ALTER TABLE courses ADD CONSTRAINT fk_teacher 
FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE;
-- verifying courses of docents
SELECT t.full_name AS docente, c.name AS curso
FROM teachers t
JOIN courses c ON t.teacher_id = c.teacher_id
WHERE t.teacher_id = 1;
-- delete docent (error)
DELETE FROM teachers WHERE teacher_id = 1;

-- error solution:
-- error description (why): courses contain inscriptions and fk of inscriptions dont have CASCADE definied. 
-- step 1: delete actual fk from inscriptions
ALTER TABLE inscriptions DROP FOREIGN KEY inscriptions_ibfk_2;

-- step 2: create it again with CASCADE
ALTER TABLE inscriptions ADD CONSTRAINT fk_inscription_course
FOREIGN KEY (course_id)
REFERENCES courses(course_id)
ON DELETE CASCADE;
-- try (good):
DELETE FROM teachers WHERE teacher_id = 1;

#3). 7 (no one course have more than 2 inscribed students):
SELECT * FROM inscriptions;
SELECT c.name AS curso, COUNT(i.student_id) AS total_estudiantes
FROM courses c
JOIN inscriptions i ON c.course_id = i.course_id
GROUP BY c.course_id, c.name
HAVING COUNT(i.student_id) >= 2;

#4). 1:
SELECT s.full_name AS student, AVG(i.final_grade) AS avg_note
FROM students s
JOIN inscriptions i ON s.student_id = i.student_id
GROUP BY s.student_id, s.full_name
HAVING AVG(i.final_grade) > (
	SELECT AVG(final_grade)
	FROM inscriptions
);


#4). 2:
SELECT DISTINCT s.career AS career
FROM students s
WHERE s.student_id IN (
	SELECT i.student_id FROM inscriptions i
	JOIN courses c ON i.course_id = c.course_id
	WHERE c.semester >= 2 	
);
#4). 3:
SELECT c.name AS course,
COUNT(i.student_id) AS total_inscribed,
ROUND(AVG(final_grade), 2) AS average,
MAX(i.final_grade) AS max_note,
MIN(i.final_grade) AS min_note,
SUM(i.final_grade) AS califications_summary
FROM courses c
JOIN inscriptions i ON c.course_id = i.course_id
GROUP BY c.course_id, c.name 
ORDER BY average DESC; 

#5):
CREATE VIEW view_academic_historial AS
SELECT s.full_name AS student, c.name AS course, t.full_name AS teacher,
c.semester AS semester, i.final_grade AS final_grade FROM students s
JOIN inscriptions i ON s.student_id = i.student_id
JOIN courses c ON i.course_id = c.course_id
JOIN teachers t ON c.teacher_id = t.teacher_id;

SELECT * FROM view_academic_historial; 