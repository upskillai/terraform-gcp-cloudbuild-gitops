# main.py

from flask import Flask, request, jsonify

app = Flask(__name__)

# Cloud Function entry point


@app.route("/", methods=["GET", "POST"])
def hello_world():
    if request.method == "GET":
        return jsonify({
            "message": "Hello from Cloud Functions 2nd Gen!",
            "method": "GET"
        })

    elif request.method == "POST":
        data = request.get_json()
        name = data.get("name", "World")
        return jsonify({
            "message": f"Hello, {name}!",
            "method": "POST"
        })

# To deploy this function in Google Cloud Function (2nd Gen), you need to expose the app object.


def main(request):
    return app(request)
