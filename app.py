from flask import Flask, render_template, request
from flaskext.mysql import MySQL

mysql = MySQL()
app = Flask(__name__)

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = '1234'
app.config['MYSQL_DATABASE_DB'] = 'shelter'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)


@app.route("/", methods=['GET'])
def main():
    return render_template('index.html')


@app.route("/sign-in", methods=['GET', 'POST'])
def sign_in():
    if request.method == 'GET':
        return render_template('sign-in.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            username = request.form['username']
            password = request.form['password']
            if username and password:
                cursor.callproc('login', [username, password])
                data = cursor.fetchall()
                if len(data) == 0:
                    return render_template('homepage.html')
                else:
                    return render_template('sign-in.html', message=data[0][0])
            else:
                return render_template('sign-in.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('sign-in.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/sign-up', methods=['GET', 'POST'])
def sign_up():
    if request.method == 'GET':
        return render_template('sign-up.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            username = request.form['username']
            password = request.form['password']
            if username and password:
                cursor.callproc('add_shelter_manager', [username, password])
                data = cursor.fetchall()
                conn.commit()
                return render_template('sign-up.html', message=data[0][0])
            else:
                return render_template('sign-up.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('sign-up.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/homepage')
def homepage():
    return render_template('homepage.html')


@app.route('/shelter-manager')
def shelter_manager():
    return render_template('shelter-manager.html')


@app.route('/shelter-manager/view', methods=['GET', 'POST'])
def view_all_shelter_managers():
    if request.method == 'GET':
        return render_template('view-shelter-manager.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('view_shelter_managers')
            data = cursor.fetchall()
            return render_template('view-shelter-manager.html', table=data)
        except Exception as e:
            return render_template('view-shelter-manager.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/shelter-manager/add', methods=['GET', 'POST'])
def add_shelter_manager():
    if request.method == 'GET':
        return render_template('add-shelter-manager.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            username = request.form['username']
            password = request.form['password']
            if username and password:
                cursor.callproc('add_shelter_manager', [username, password])
                data = cursor.fetchall()
                conn.commit()
                return render_template('add-shelter-manager.html', message=data[0][0])
            else:
                return render_template('add-shelter-manager.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('add-shelter-manager.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/shelter-manager/update', methods=['GET', 'POST'])
def update_shelter_manager():
    if request.method == 'GET':
        return render_template('update-shelter-manager.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            old_username = request.form['old_username']
            new_username = request.form['new_username']
            new_password = request.form['new_password']
            if old_username and new_username and new_password:
                cursor.callproc('update_shelter_manager', [old_username, new_username, new_password])
                data = cursor.fetchall()
                conn.commit()
                return render_template('update-shelter-manager.html', message=data[0][0])
            else:
                return render_template('update-shelter-manager.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('update-shelter-manager.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/shelter-manager/delete', methods=['GET', 'POST'])
def delete_shelter_manager():
    if request.method == 'GET':
        return render_template('delete-shelter-manager.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            username = request.form['username']
            if username:
                cursor.callproc('delete_shelter_manager', [username])
                data = cursor.fetchall()
                conn.commit()
                return render_template('delete-shelter-manager.html', message=data[0][0])
            else:
                return render_template('delete-shelter-manager.html', message='Fill the field.')
        except Exception as e:
            return render_template('delete-shelter-manager.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/caretaker')
def caretaker():
    return render_template('caretaker.html')


@app.route('/caretaker/view', methods=['GET', 'POST'])
def view_all_caretakers():
    if request.method == 'GET':
        return render_template('view-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('view_caretakers')
            data = cursor.fetchall()
            return render_template('view-caretaker.html', table=data)
        except Exception as e:
            return render_template('view-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/caretaker/rank', methods=['GET', 'POST'])
def rank_caretakers():
    if request.method == 'GET':
        return render_template('rank-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('rank_caretakers')
            data = cursor.fetchall()
            return render_template('rank-caretaker.html', table=data)
        except Exception as e:
            return render_template('rank-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/caretaker/add', methods=['GET', 'POST'])
def add_caretaker():
    if request.method == 'GET':
        return render_template('add-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            if name and surname:
                cursor.callproc('add_caretaker', [name, surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('add-caretaker.html', message=data[0][0])
            else:
                return render_template('add-caretaker.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('add-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/caretaker/update', methods=['GET', 'POST'])
def update_caretaker():
    if request.method == 'GET':
        return render_template('update-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            old_name = request.form['old_name']
            old_surname = request.form['old_surname']
            new_name = request.form['new_name']
            new_surname = request.form['new_surname']
            if old_name and old_surname and new_name and new_surname:
                cursor.callproc('update_caretaker', [old_name, old_surname, new_name, new_surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('update-caretaker.html', message=data[0][0])
            else:
                return render_template('update-caretaker.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('update-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/caretaker/delete', methods=['GET', 'POST'])
def delete_caretaker():
    if request.method == 'GET':
        return render_template('delete-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            if name and surname:
                cursor.callproc('delete_caretaker', [name, surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('delete-caretaker.html', message=data[0][0])
            else:
                return render_template('delete-caretaker.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('delete-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal')
def animal():
    return render_template('animal.html')


@app.route('/animal/view', methods=['GET', 'POST'])
def view_all_animals():
    if request.method == 'GET':
        return render_template('view-animal.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('view_animals')
            data = cursor.fetchall()
            return render_template('view-animal.html', table=data)
        except Exception as e:
            return render_template('view-animal.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/of-caretaker', methods=['GET', 'POST'])
def view_animals_of_caretaker():
    if request.method == 'GET':
        return render_template('view-animal-of-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            if name and surname:
                cursor.callproc('view_animals_of_caretaker', [name, surname])
                data = cursor.fetchall()
                return render_template('view-animal-of-caretaker.html', table=data)
            else:
                return render_template('view-animal-of-caretaker.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('view-animal-of-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/of-sponsor', methods=['GET', 'POST'])
def view_animals_of_sponsor():
    if request.method == 'GET':
        return render_template('view-animal-of-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            if name and surname:
                cursor.callproc('view_animals_of_sponsor', [name, surname])
                data = cursor.fetchall()
                return render_template('view-animal-of-sponsor.html', table=data)
            else:
                return render_template('view-animal-of-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('view-animal-of-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/of-species', methods=['GET', 'POST'])
def view_animals_of_species():
    if request.method == 'GET':
        return render_template('view-animal-of-species.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            species = request.form['species']
            if species:
                cursor.callproc('view_animals_of_species', [species])
                data = cursor.fetchall()
                return render_template('view-animal-of-species.html', table=data)
            else:
                return render_template('view-animal-of-species.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('view-animal-of-species.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/without-sponsor', methods=['GET', 'POST'])
def view_animals_without_sponsor():
    if request.method == 'GET':
        return render_template('view-animal-without-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('view_animals_without_sponsor')
            data = cursor.fetchall()
            return render_template('view-animal-without-sponsor.html', table=data)
        except Exception as e:
            return render_template('view-animal-without-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/add', methods=['GET', 'POST'])
def add_animal():
    if request.method == 'GET':
        return render_template('add-animal.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            age = request.form['age']
            species = request.form['species']
            if name and age and species:
                cursor.callproc('add_animal', [name, age, species])
                data = cursor.fetchall()
                conn.commit()
                return render_template('add-animal.html', message=data[0][0])
            else:
                return render_template('add-animal.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('add-animal.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/update', methods=['GET', 'POST'])
def update_animal():
    if request.method == 'GET':
        return render_template('update-animal.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            old_name = request.form['old_name']
            new_name = request.form['new_name']
            new_age = request.form['new_age']
            new_species = request.form['new_species']
            if old_name and new_name and new_age and new_species:
                cursor.callproc('update_animal', [old_name, new_name, new_age, new_species])
                data = cursor.fetchall()
                conn.commit()
                return render_template('update-animal.html', message=data[0][0])
            else:
                return render_template('update-animal.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('update-animal.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/assign-sponsor', methods=['GET', 'POST'])
def assign_sponsor():
    if request.method == 'GET':
        return render_template('assign-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            sponsor_name = request.form['sponsor_name']
            sponsor_surname = request.form['sponsor_surname']
            if name and sponsor_name and sponsor_surname:
                cursor.callproc('assign_sponsor', [name, sponsor_name, sponsor_surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('assign-sponsor.html', message=data[0][0])
            else:
                return render_template('assign-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('assign-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/unassign-sponsor', methods=['GET', 'POST'])
def unassign_sponsor():
    if request.method == 'GET':
        return render_template('unassign-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            if name:
                cursor.callproc('unassign_sponsor', [name])
                data = cursor.fetchall()
                conn.commit()
                return render_template('unassign-sponsor.html', message=data[0][0])
            else:
                return render_template('unassign-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('unassign-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/change-caretaker', methods=['GET', 'POST'])
def change_caretaker():
    if request.method == 'GET':
        return render_template('change-caretaker.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            caretaker_name = request.form['caretaker_name']
            caretaker_surname = request.form['caretaker_surname']
            if name and caretaker_name and caretaker_surname:
                cursor.callproc('change_caretaker', [name, caretaker_name, caretaker_surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('change-caretaker.html', message=data[0][0])
            else:
                return render_template('change-caretaker.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('change-caretaker.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/animal/delete', methods=['GET', 'POST'])
def delete_animal():
    if request.method == 'GET':
        return render_template('delete-animal.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            if name:
                cursor.callproc('delete_animal', [name])
                data = cursor.fetchall()
                conn.commit()
                return render_template('delete-animal.html', message=data[0][0])
            else:
                return render_template('delete-animal.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('delete-animal.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/sponsor')
def sponsor():
    return render_template('sponsor.html')


@app.route('/sponsor/view', methods=['GET', 'POST'])
def view_all_sponsors():
    if request.method == 'GET':
        return render_template('view-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            cursor.callproc('view_sponsors')
            data = cursor.fetchall()
            return render_template('view-sponsor.html', table=data)
        except Exception as e:
            return render_template('view-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/sponsor/add', methods=['GET', 'POST'])
def add_sponsor():
    if request.method == 'GET':
        return render_template('add-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            phone = request.form['phone']
            if name and surname and phone:
                cursor.callproc('add_sponsor', [name, surname, phone])
                data = cursor.fetchall()
                conn.commit()
                return render_template('add-sponsor.html', message=data[0][0])
            else:
                return render_template('add-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('add-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/sponsor/update', methods=['GET', 'POST'])
def update_sponsor():
    if request.method == 'GET':
        return render_template('update-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            old_name = request.form['old_name']
            old_surname = request.form['old_surname']
            new_name = request.form['new_name']
            new_surname = request.form['new_surname']
            new_phone = request.form['new_phone']
            if old_name and old_surname and new_name and new_surname and new_phone:
                cursor.callproc('update_sponsor', [old_name, old_surname, new_name, new_surname, new_phone])
                data = cursor.fetchall()
                conn.commit()
                return render_template('update-sponsor.html', message=data[0][0])
            else:
                return render_template('update-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('update-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


@app.route('/sponsor/delete', methods=['GET', 'POST'])
def delete_sponsor():
    if request.method == 'GET':
        return render_template('delete-sponsor.html')
    else:
        conn = mysql.connect()
        cursor = conn.cursor()
        try:
            name = request.form['name']
            surname = request.form['surname']
            if name and surname:
                cursor.callproc('delete_sponsor', [name, surname])
                data = cursor.fetchall()
                conn.commit()
                return render_template('delete-sponsor.html', message=data[0][0])
            else:
                return render_template('delete-sponsor.html', message='Fill all the fields.')
        except Exception as e:
            return render_template('delete-sponsor.html', message=e[1])
        finally:
            cursor.close()
            conn.close()


if __name__ == "__main__":
    app.run(debug=True)
