from flask import Flask, request, jsonify

app = Flask(__name__)

@app.post("/llm")
def llm():
    data = request.json
    prompt = data.get("prompt", "")
    return jsonify({"response": f"LLM-MOCK: ricevuto -> {prompt}"})

app.run(host="0.0.0.0", port=8080)
