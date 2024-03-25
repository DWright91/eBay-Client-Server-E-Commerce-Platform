# eBay-Client-Server-E-Commerce-Platform

General Information:

The goal for this project was to create an Ebay-style shop where buyers can shop
products provided to them by sellers. The client features a single login for both users where they
pick their respective role - buyer or seller. The program then either activates the buyer client or
the seller client.

    • The login client uses the bycrypt library (and our SQL server uses pg_bycrypt) to encrypt
    users passwords. A salt value is used to differentiate the encryption, so even if two users enter
    the same password it will be different values in the table. Bycrypt uses the Blowfish symmetric
    key block cipher algorithm which employs a method called key stretching to protect against
    brute force attacks. The program also does password hashing to check password validity, so
    nobody’s password is ever decrypted when performing a check.

    • Buyers can change their account info, view products, add products to a cart, view reviews
    for a product, or view previous orders. This is all done via a main menu that opens windows to
    each feature when their respective button is clicked.

    • Sellers can add new products, view how users interact with their items (by viewing
    reviews and seeing how many people ordered their product) and of course change their account
    info.

    • Our program uses PostgreSQL to handle the relational database side of our program. This
    contains things like buyers, sellers, products, orders, etc. MongoDB was used to store the
    reviews for products. Our PostgreSQL database contains a few functions for hashing passwords
    as well as some indexes for attributes that are used to search for products within our app. Our
    MongoDB has an index on productid so reviews for a product can be fetched quickly.

    • The GUI was created using the Python library Tkinter. It’s a free and lightweight package
    that creates simple yet effective GUIs. While it may look like a program that ran on Windows
    XP, the layout was designed to be intuitive to use.

    • Our program uses the container Docker to ensure execution consistency across platforms.
    Our docker program knows all necessary information like Python version and libraries for
    running the app and ensures that anyone who installs it will have it work properly on their
    machine.

    • To exit the program, the user clicks save and exit. This will save all the changes made
    permanently to the databases.

----------------------------------------------------------------------------------------
How to Run:

The program is ran by running CSCI414_Shop4All_Login.py. The docker knows this already so
when deployed all it would take is running the container. The program won’t actually run on any
machine aside from mine because we used a localhost for the databases, but if it were actually
deployed servers would host the connection.

----------------------------------------------------------------------------------------
How Logging in Works:

Logging in is a straightforward process that uses the function below. It gets the hashed password
associated with the entered email, hashes the password entered using the salt saved in the
database, and checks to see if both encrpytions match. This method is secure as the saved
password is never decrypted and the checked password is hashed before being checked.

    def authenticate(username, password, role):
    if role == "Buyer":
    cursor.execute("SELECT salt FROM buyers WHERE email = %s;",
    (username,))
    else:
    cursor.execute("SELECT salt FROM sellers WHERE email = %s;",
    (username,))
    record = cursor.fetchall()
    if not record:
    return False
    else:
    check_password = bcrypt.hashpw(password.encode('utf-8'),
    record[0][0].encode('utf-8'))
    if role == "Buyer":
    cursor.execute("SELECT name FROM buyers WHERE
    password_hash::bytea = %s;", (check_password,))
    else:
    cursor.execute("SELECT name FROM sellers WHERE
    password_hash::bytea = %s;", (check_password,))
    record = cursor.fetchall()
    if not record:
    return False
    else:
    return True

----------------------------------------------------------------------------------------
How Client Information is Changed:

Clients (buyers/sellers) can change the information they registered with by choosing to do so at
their respective main menus. The logic for both operations is very similar, we just change which
tables we call. Below is the generic function used to create a window prompting for a new value
for whatever was requested to be changed. It’s used to change all the data except the password,
which requires extra authentication to configure.

    # Generic function used to change client information
    def change_template(title, label_text, change_function):
    # Create a new window for changing client information
    global change_window
    change_window = tk.Toplevel(main_window)
    change_window.title(title)
    change_window.geometry("300x300")
    # Label for what we're changing
    label = tk.Label(change_window, text=label_text, font=("Times New
    Roman", 12))
    label.pack(pady=10)
    # Entry field for the new value
    entry = tk.Entry(change_window, width=30)
    entry.pack(pady=10)
    # Change button
    def change():
    new_value = entry.get()
    if new_value:
    if change_function(cursor, buyerID, new_value) == True:
    messagebox.showinfo("Success", f"{title} operation was
    successful!")
    change_window.destroy()
    else:
    messagebox.showinfo("Failure", "Operation failed for an
    unknown reason.")
    else:
    messagebox.showwarning("Warning", "Please enter a new value.")
    change_button = tk.Button(change_window, text="Change",
    command=change)
    change_button.pack(pady=5)
    # Back button to close the change_window
    back_button = tk.Button(change_window, text="Back",
    command=change_window.destroy)
    back_button.pack(pady=10)
    
----------------------------------------------------------------------------------------
How Buyers Shop for Products:

Buyers select the view products page to begin shopping. Everything they need to see is in the
listbox, but should they want to view product reviews they can select the product and then click
view reviews. Buyers can add items to their cart in whichever quantity they like. Once they have
finished, they can view their cart and make any changes they wish before finalizing the order.
After the order is finished they can view it in the previous orders page.

----------------------------------------------------------------------------------------
How Sellers Push Their Items:

Sellers can view all the products that have ever been on the market in a single window. We added
a search function incase sellers have hundreds or thousands of products they sell. They can
update products, add new ones, or remove old ones. Removing a product does not delete it from
the database so that information can still be accessed by buyers who previously purchased it.
Instead, the stock is set to -1 which prevents it from being shown in the product listing unless
you’re the seller who sold it or a previous buyer.

----------------------------------------------------------------------------------------
Conclusion:

Our goal was to create a simple to use shopping program that didn’t overwhelm it’s users,
program features a very straightforward UI, interacts with the databases in an optimized way, 
and is contained within a docker file to provide an experience that can run on any machine.
