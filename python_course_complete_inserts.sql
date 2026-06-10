INSERT INTO units (id, course_id, title, unit_order) VALUES
('u1-python-basics', '550e8400-e29b-41d4-a716-446655440000', 'Python Basics', 0),
('u2-making-decisions', '550e8400-e29b-41d4-a716-446655440000', 'Making Decisions', 1),
('u3-repeating-tasks', '550e8400-e29b-41d4-a716-446655440000', 'Repeating Tasks', 2),
('u4-lists', '550e8400-e29b-41d4-a716-446655440000', 'Lists', 3),
('u5-working-with-list-data', '550e8400-e29b-41d4-a716-446655440000', 'Working with List Data', 4),
('u6-data-structures', '550e8400-e29b-41d4-a716-446655440000', 'Data Structures', 5),
('u7-reusable-code', '550e8400-e29b-41d4-a716-446655440000', 'Reusable Code', 6),
('u8-handling-errors', '550e8400-e29b-41d4-a716-446655440000', 'Handling Errors', 7),
('u9-pythons-power', '550e8400-e29b-41d4-a716-446655440000', 'Python''s Power', 8),
('u10-classes-objects', '550e8400-e29b-41d4-a716-446655440000', 'Classes & Objects', 9),
('u11-oop-concepts', '550e8400-e29b-41d4-a716-446655440000', 'OOP Concepts', 10);

-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u1-python-basics', 'Hello World and Comments', '1/1.1.json', 0, 0),
('u1-python-basics', 'Creating Variables', '1/1.2.json', 0, 1),
('u1-python-basics', 'Using Variables', '1/1.3.json', 0, 2),
('u1-python-basics', 'Naming rules & assignments', '1/1.4.json', 0, 3),
('u1-python-basics', 'Practice', '1/1.10.json', 0, 4),
('u1-python-basics', 'Data Types', '1/1.5.json', 0, 5),
('u1-python-basics', 'Type Conversion', '1/1.6.json', 0, 6),
('u1-python-basics', 'Practice', '1/1.11.json', 0, 7),
('u1-python-basics', 'String Concatenation and Formatting', '1/1.7.json', 0, 8),
('u1-python-basics', 'String Operations', '1/1.8.json', 0, 9),
('u1-python-basics', 'Practice', '1/1.12.json', 0, 10),
('u1-python-basics', 'Basic Math Operations', '1/1.9.json', 0, 11),
('u1-python-basics', 'Practice', '1/1.13.json', 0, 12);

-- ================================
-- Unit 2: Making Decisions (10 bytes: 6 lessons + 4 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u2-making-decisions', 'Comparison Operators', '2/2.1.json', 0, 0),
('u2-making-decisions', 'Logical Operators', '2/2.2.json', 0, 1),
('u2-making-decisions', 'Practice Lesson', '2/2.7.json', 0, 2),
('u2-making-decisions', 'If Statements', '2/2.3.json', 0, 3),
('u2-making-decisions', 'Practice Lesson', '2/2.8.json', 0, 4),
('u2-making-decisions', 'Elif & Else', '2/2.4.json', 0, 5),
('u2-making-decisions', 'Practice Lesson', '2/2.10.json', 0, 6),
('u2-making-decisions', 'Nested Conditionals', '2/2.5.json', 0, 7),
('u2-making-decisions', 'Match', '2/2.6.json', 0, 8),
('u2-making-decisions', 'Practice Lesson', '2/2.9.json', 0, 9);

-- ================================
-- Unit 3: Repeating Tasks (8 bytes: 5 lessons + 3 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u3-repeating-tasks', 'While Loops', '3/3.1.json', 0, 0),
('u3-repeating-tasks', 'Practice Lesson', '3/3.6.json', 0, 1),
('u3-repeating-tasks', 'Range Function', '3/3.2.json', 0, 2),
('u3-repeating-tasks', 'For Loops', '3/3.3.json', 0, 3),
('u3-repeating-tasks', 'Loop Control (Break and Continue)', '3/3.4.json', 0, 4),
('u3-repeating-tasks', 'Practice Lesson', '3/3.7.json', 0, 5),
('u3-repeating-tasks', 'Nested Loops', '3/3.5.json', 0, 6),
('u3-repeating-tasks', 'Practice Lesson', '3/3.8.json', 0, 7);

-- ================================
-- Unit 4: Lists (9 bytes: 6 lessons + 3 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u4-lists', 'Creating List', '4/4.1.json', 0, 0),
('u4-lists', 'Accessing List', '4/4.2.json', 0, 1),
('u4-lists', 'Practice Lesson', '4/4.7.json', 0, 2),
('u4-lists', 'Updating List', '4/4.3.json', 0, 3),
('u4-lists', 'Removing from List', '4/4.4.json', 0, 4),
('u4-lists', 'Practice Lesson', '4/4.8.json', 0, 5),
('u4-lists', 'Looping & Checking Lists', '4/4.5.json', 0, 6),
('u4-lists', 'Slicing & Combining Lists', '4/4.6.json', 0, 7),
('u4-lists', 'Practice Lesson', '4/4.9.json', 0, 8);

-- ================================
-- Unit 5: Working with List Data (7 bytes: 5 lessons + 2 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u5-working-with-list-data', 'Sorting Lists', '5/5.1.json', 0, 0),
('u5-working-with-list-data', 'Reversing & Counting', '5/5.2.json', 0, 1),
('u5-working-with-list-data', 'Practice Lesson', '5/5.6.json', 0, 2),
('u5-working-with-list-data', 'Finding in Lists', '5/5.3.json', 0, 3),
('u5-working-with-list-data', 'Min, Max and Sum', '5/5.4.json', 0, 4),
('u5-working-with-list-data', 'Copying Lists', '5/5.5.json', 0, 5),
('u5-working-with-list-data', 'Practice Lesson', '5/5.7.json', 0, 6);

-- ================================
-- Unit 6: Data Structures (10 bytes: 7 lessons + 3 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u6-data-structures', 'Tuples Basics', '6/6.1.json', 0, 0),
('u6-data-structures', 'Working with Tuples', '6/6.2.json', 0, 1),
('u6-data-structures', 'Practice Lesson', '6/6.8.json', 0, 2),
('u6-data-structures', 'Dictionary Basics', '6/6.3.json', 0, 3),
('u6-data-structures', 'Working with Dictionaries', '6/6.4.json', 0, 4),
('u6-data-structures', 'Looping Through Dictionaries', '6/6.5.json', 0, 5),
('u6-data-structures', 'Practice Lesson', '6/6.9.json', 0, 6),
('u6-data-structures', 'Set Basics', '6/6.6.json', 0, 7),
('u6-data-structures', 'Set Operations', '6/6.7.json', 0, 8),
('u6-data-structures', 'Practice Lesson', '6/6.10.json', 0, 9);

-- ================================
-- Unit 7: Reusable Code (10 bytes: 7 lessons + 3 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u7-reusable-code', 'Function Basics', '7/7.1.json', 0, 0),
('u7-reusable-code', 'Parameters', '7/7.2.json', 0, 1),
('u7-reusable-code', 'Practice Lesson', '7/7.8.json', 0, 2),
('u7-reusable-code', 'Return Values', '7/7.3.json', 0, 3),
('u7-reusable-code', 'Default Parameters', '7/7.4.json', 0, 4),
('u7-reusable-code', 'Practice Lesson', '7/7.9.json', 0, 5),
('u7-reusable-code', 'Variable Scope', '7/7.5.json', 0, 6),
('u7-reusable-code', 'Functions with Conditionals', '7/7.6.json', 0, 7),
('u7-reusable-code', 'Functions with Loops', '7/7.7.json', 0, 8),
('u7-reusable-code', 'Practice Lesson', '7/7.10.json', 0, 9);

-- ================================
-- Unit 8: Handling Errors (5 bytes: 3 lessons + 2 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u8-handling-errors', 'Try & Except', '8/8.1.json', 0, 0),
('u8-handling-errors', 'Finally Blocks', '8/8.2.json', 0, 1),
('u8-handling-errors', 'Practice', '8/8.4.json', 0, 2),
('u8-handling-errors', 'Raising Exceptions', '8/8.3.json', 0, 3),
('u8-handling-errors', 'Practice Lesson', '8/8.5.json', 0, 4);

-- ================================
-- Unit 9: Python's Power (5 bytes: 4 lessons + 1 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u9-pythons-power', 'Modules & Importing', '9/9.1.json', 0, 0),
('u9-pythons-power', 'Random Module', '9/9.2.json', 0, 1),
('u9-pythons-power', 'Math Module', '9/9.3.json', 0, 2),
('u9-pythons-power', 'DateTime Module', '9/9.4.json', 0, 3),
('u9-pythons-power', 'Practice Lesson', '9/9.5.json', 0, 4);

-- ================================
-- Unit 10: Classes & Objects (4 bytes: 3 lessons + 1 practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u10-classes-objects', 'Creating Classes', '10/10.1.json', 0, 0),
('u10-classes-objects', 'Methods', '10/10.2.json', 0, 1),
('u10-classes-objects', '__init__ Constructor', '10/10.3.json', 0, 2),
('u10-classes-objects', 'Practice Lesson', '10/10.4.json', 0, 3);

-- ================================
-- Unit 11: OOP Concepts (3 bytes: 3 lessons, no practice)
-- ================================
INSERT INTO course_bytes (unit_id, title, content_json_url, total_blocks, byte_order) VALUES
('u11-oop-concepts', 'Encapsulation', '11/11.1.json', 0, 0),
('u11-oop-concepts', 'Inheritance', '11/11.2.json', 0, 1),
('u11-oop-concepts', 'Polymorphism', '11/11.3.json', 0, 2);
