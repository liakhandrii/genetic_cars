from flask import Flask
from flask.ext.pymongo import PyMongo
from bson.json_util import dumps
import os

app = Flask('generations')
mongo = PyMongo(app)

@app.route('/connect')
def home_page():
	test = mongo.db.generations.find({})
	view_this = dumps(test)
	return str(view_this)


