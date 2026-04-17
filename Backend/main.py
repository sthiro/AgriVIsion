from flask import Flask, request, jsonify
import mysql.connector

# Initialize Flask app
app = Flask(__name__)

# Function to connect to the database
def get_db_connection():
    return mysql.connector.connect(
        host='localhost',          # Update if your database is hosted elsewhere
        user='root',               # Your MySQL username
        password='stjohns2025',    # Your MySQL password
        database='agri_vision'     # Your database name
    )

# Define the home route
@app.route('/')
def home():
    return "Welcome to Agri-vision API. Use /api/demand to fetch demand data or /api/farmers to manage vegetables."

# Define an endpoint to fetch data from the `ratio` table
@app.route('/api/demand', methods=['GET'])
def get_ratio():
    connection = get_db_connection()
    cursor = connection.cursor()

    # Define the query to fetch data from the table
    query = "SELECT * FROM ratio"
    cursor.execute(query)

    # Fetch all rows from the table
    rows = cursor.fetchall()

    # Get column names for the table
    columns = [desc[0] for desc in cursor.description]

    # Convert the rows into a list of dictionaries
    data = [dict(zip(columns, row)) for row in rows]

    # Close the cursor and connection
    cursor.close()
    connection.close()

    # Return JSON data
    return jsonify(data)

# Define an endpoint to add a vegetable to the `farmers` table
@app.route('/api/farmers/add', methods=['POST'])
def add_vegetable():
    data = request.json
    veg_id = data.get("veg_id")  # Vegetable ID
    area = data.get("area")   # Area in acres

    if not veg_id or not area:
        return jsonify({"error": "Missing 'veg_id' or 'area' parameter"}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        # Insert or update the vegetable entry in the farmers table
        query = """
        INSERT INTO cultivation (veg_id, area)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE area = VALUES(area)
        """
        cursor.execute(query, (veg_id, area))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Vegetable added or updated successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Define an endpoint to add a new farmer ID to the `farmers` table
@app.route('/api/farmers/new_farmer_id', methods=['POST'])
def add_new_farmer():
    data = request.json
    name = data.get("name")   # Farmer's name

    if not name:
        return jsonify({"error": "Missing 'name' parameter"}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        # Insert a new farmer entry into the farmers table
        query = """
        INSERT INTO farmers (name) VALUES (%s);
        """
        cursor.execute(query, (name,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "New farmer added successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Define an endpoint to delete a vegetable from the `farmers` table
@app.route('/api/farmers/delete', methods=['DELETE'])
def delete_vegetable():
    data = request.json
    veg_id = data.get("veg_id")  # Vegetable ID

    if not veg_id:
        return jsonify({"error": "Missing 'veg_id' parameter"}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        # Delete the vegetable entry from the farmers table
        query = "DELETE FROM cultivation WHERE veg_id = %s"
        cursor.execute(query, (veg_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Vegetable deleted successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


#http://192.168.1.114:5000/