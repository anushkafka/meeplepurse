CREATE DATABASE meeplepurse;

CREATE TABLE users
(
  id serial PRIMARY KEY,
  email VARCHAR(225) unique,
  currency VARCHAR(3),
  usrname VARCHAR(225),
  img_url bytea,
  est_budget NUMERIC CHECK (est_budget > 0),
  password_digest VARCHAR(400) not NULL
);

CREATE TABLE purchases(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users (id) ON DELETE RESTRICT,
  boardgame_id VARCHAR(50),
  boardgame_title VARCHAR(300),
  price NUMERIC CHECK(price > 0)
);
-- CREATE TABLE budgets
-- (
--   id serial PRIMARY KEY,
--   user_id INTEGER REFERENCES users (id) ON DELETE RESTRICT,
--   fiscal_year VARCHAR(4),
--   currency VARCHAR(3),
--   est_budget NUMERIC CHECK (est_budget > 0)
-- );

-- CREATE TABLE boardgames
-- (
--   id serial PRIMARY KEY,
--   budget_id INTEGER REFERENCES budgets (id) ON DELETE RESTRICT,
--   title VARCHAR(300) not null,
--   currency VARCHAR(3),
--   price NUMERIC CHECK(price > 0)
-- );

-- CREATE TABLE user_boardgames
-- (
--   id SERIAL PRIMARY KEY,
--   boardgame_id INTEGER REFERENCES boardgames (id) ON DELETE RESTRICT,
--   user_id INTEGER REFERENCES users (id) ON DELETE RESTRICT
-- );

-- CREATE TABLE comments (
--  id SERIAL PRIMARY KEY,
--  body VARCHAR(500) NOT NULL ,
--  dish_id INTEGER NOT NULL,
--  FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE RESTRICT
--  );
INSERT INTO users
  (usrname,pwd,email)
VALUES
  ('anu', 'pwd', 'email')

  
-- create TABLE likes(
--   id serial PRIMARY KEY,
--   user_id INTEGER not null,
--   post_id INTEGER not null,
--   FOREIGN KEY (user_id) REFERENCES users(id) on DELETE RESTRICT
--   );