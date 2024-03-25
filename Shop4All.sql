CREATE TABLE buyers (name VARCHAR(50),
	address VARCHAR(80),
	phone VARCHAR(10),
	email VARCHAR(50),
	password_hash VARCHAR(65),
	salt VARCHAR(32),
	buyerID SERIAL PRIMARY KEY
);

CREATE TABLE sellers (name VARCHAR(50),
	address VARCHAR(80),
	phone VARCHAR(10),
	email VARCHAR(50),
	password_hash VARCHAR(65),
	salt VARCHAR(32),
	sellerID SERIAL PRIMARY KEY
);

CREATE TABLE categories (name VARCHAR(40),
	catagoryID SERIAL PRIMARY KEY
);

CREATE TABLE products (name VARCHAR(50),
	stock INTEGER,
	price REAL,
	productID SERIAL PRIMARY KEY,
	sellerID INTEGER REFERENCES sellers(sellerID),
	catagoryID INTEGER REFERENCES catagories(catagoryID)
);

CREATE TABLE orders (date TIMESTAMP,
	orderID SERIAL PRIMARY KEY,
	buyerID INTEGER REFERENCES buyers(buyerID)
);

CREATE TABLE orderItems (orderID INTEGER REFERENCES orders(orderID),
	productID INTEGER REFERENCES products(productID),
	quantity INTEGER,
	total_price REAL
);

CREATE TABLE reviews (reviewText VARCHAR(250),
	productID INTEGER REFERENCES products(productID),
	buyerID INTEGER REFERENCES buyers(buyerID)
);

CREATE TABLE admins (name VARCHAR(70),
	email VARCHAR(80),
	username VARCHAR(30),
	password_hash VARCHAR(65),
	salt VARCHAR(32),
	adminID SERIAL PRIMARY KEY
);

CREATE OR REPLACE FUNCTION hash_password()
RETURNS TRIGGER AS $$
BEGIN
	NEW.salt := gen_salt('bf');
	NEW.password_hash := crypt(NEW.password_hash, NEW.salt);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_buyer
BEFORE INSERT ON buyers
FOR EACH ROW
EXECUTE FUNCTION hash_password();

CREATE TRIGGER before_seller
BEFORE INSERT ON sellers
FOR EACH ROW
EXECUTE FUNCTION hash_password();

CREATE TRIGGER before_admin
BEFORE INSERT ON admins
FOR EACH ROW
EXECUTE FUNCTION hash_password();
