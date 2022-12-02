from flask import Flask, jsonify, request
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
import os, binascii
import base64

basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    SECRET_KEY = binascii.hexlify(os.urandom(24))
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'piou.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

app = Flask(__name__)
with app.app_context():
    app.config.from_object(Config)
    db = SQLAlchemy( app )

    db.create_all()

class Record(db.Model):
    """
    Represents a bird recording

    Attributes:
    -----------
    id: the unique id of the entry (int) 
        - Primary key
    time: the start time of the record (unix timestamp)
    bird_en: the English name of the predicted bird (string)
    bird_lt: the Latin name of the predicted bird (string)
    confidence: the confidence of the prediction (int)
    data: the content of the mp3 file (LargeBinary)
    humidity: the humidity recorded (float)
    temperature: the temperature recorded (float)
    pressure: the pressure recorded (float)
    """
    id = db.Column(db.Integer, primary_key=True)
    time = db.Column(db.DateTime)
    bird_en = db.Column(db.String(50))
    bird_lt = db.Column(db.String(50))
    confidence = db.Column(db.Float)
    data = db.Column(db.LargeBinary)

    #Sensor data
    
    humidity = db.Column(db.Float)
    temperature = db.Column(db.Float)
    pressure = db.Column(db.Float)
    

def add_record(time, bird_en, bird_lt, confidence, file, humidity, temperature, pressure):
    """
    Add a new music to the database
    """
    new_record = Record(time = time, bird_en = bird_en, bird_lt = bird_lt, confidence = confidence, data = file.read(), temperature = temperature, humidity = humidity, pressure = pressure)

    db.session.add(new_record)
    db.session.commit()

def query_data():
    return Record.query.all()

with app.app_context():

    db.create_all()
    db.session.commit()

@app.route('/')
def index():
    return 'Hello world'

@app.route('/getdata', methods = ['GET'])
def get_data():
    dictionary = {}
    data = query_data()
    for element in data:
        dictionary[element.id] = {}
        dictionary[element.id]['time'] = int(element.time.timestamp())
        dictionary[element.id]['bird_en'] = element.bird_en
        dictionary[element.id]['bird_lt'] = element.bird_lt
        dictionary[element.id]['confidence'] = element.confidence
        dictionary[element.id]['data'] = base64.b64encode(element.data).decode('utf-8') #data is encoded to base64 byte array then to utf-8 string
        dictionary[element.id]['humidity'] = element.humidity
        dictionary[element.id]['temperature'] = element.temperature
        dictionary[element.id]['pressure'] = element.pressure

    #TODO : Clear the database

    return jsonify(dictionary)  

@app.route('/postdata', methods = ['POST'])
def upload():
    time = datetime.fromtimestamp(int(request.form['Time']))
    bird_en = request.form['Bird_EN']
    bird_lt = request.form['Bird_LT']
    confidence = request.form['Confidence']
    file = request.files['Audio']

    # TODO : Ask data from the arduino here
    thank_you_arduino = (10.0, 20.4, 100.5)
    humidity = thank_you_arduino[0]
    temperature = thank_you_arduino[1]
    pressure = thank_you_arduino[2]    
    #

    add_record(time, bird_en, bird_lt, confidence, file, humidity, temperature, pressure)

    return "Thank you for your data"

if __name__ == '__main__':
    # app.run(debug=True, host='2.9.18.4')
    app.run(debug=True, host='0.0.0.0')

# Piou piou