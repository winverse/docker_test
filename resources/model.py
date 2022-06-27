from flask import request, jsonify, Response, abort
from flask_restful import Resource


class UpdateModel(Resource):
    def put():
        return "update_model"
