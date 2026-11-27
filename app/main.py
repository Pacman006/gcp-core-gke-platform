import time
from flask import Flask, jsonify, request, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQ_COUNT = Counter(
    "platform_http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
REQ_LATENCY = Histogram(
    "platform_http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
)

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        latency = time.time() - getattr(request, "start_time", time.time())
        REQ_LATENCY.labels(endpoint=request.path).observe(latency)
        REQ_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=str(response.status_code),
        ).inc()
    return response

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
