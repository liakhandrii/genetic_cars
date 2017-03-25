from flask import Flask
from flask.ext.pymongo import PyMongo
from bson.json_util import dumps

app = Flask('test')
mongo = PyMongo(app)

@app.route('/')
def home_page():
	test = mongo.db.events.find({})
	view_this = dumps(test)
	return str(view_this)