import os
from flask import Flask, render_template_string
import requests

app = Flask(__name__)

BACKEND_HOST = os.environ.get("BACKEND_HOST", "backend")
BACKEND_PORT = os.environ.get("BACKEND_PORT", "5000")
BACKEND_URL = f"http://{BACKEND_HOST}:{BACKEND_PORT}"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Store Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; color: #333; }
        .header { background: #1a73e8; color: white; padding: 1.5rem 2rem; }
        .header h1 { font-size: 1.5rem; }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
        .stat-card { background: white; border-radius: 8px; padding: 1.5rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-card h3 { color: #666; font-size: 0.85rem; text-transform: uppercase; margin-bottom: 0.5rem; }
        .stat-card .value { font-size: 1.8rem; font-weight: bold; color: #1a73e8; }
        .section { background: white; border-radius: 8px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .section h2 { margin-bottom: 1rem; color: #333; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; }
        .status { padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.8rem; font-weight: 500; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-processing { background: #cce5ff; color: #004085; }
        .error { background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 8px; }
        .warning { background: #fff3cd; color: #856404; padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; }
        .warning strong { display: block; margin-bottom: 0.25rem; }
        .empty-state { text-align: center; padding: 2rem; color: #666; font-style: italic; }
        .health { display: inline-block; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; }
        .health-ok { background: #d4edda; color: #155724; }
        .health-err { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Store Dashboard</h1>
        <span class="health {{ 'health-ok' if backend_healthy else 'health-err' }}">
            Backend: {{ 'Connected' if backend_healthy else 'Disconnected' }}
        </span>
    </div>
    <div class="container">
        {% if error %}
        <div class="error">
            <strong>Error:</strong> {{ error }}
        </div>
        {% else %}
        {% if db_empty %}
        <div class="warning">
            <strong>⚠ Database Empty</strong>
            The database does not contain any data. Products and orders will not be displayed until data is loaded.
        </div>
        {% endif %}
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Products</h3>
                <div class="value">{{ stats.total_products }}</div>
            </div>
            <div class="stat-card">
                <h3>Total Orders</h3>
                <div class="value">{{ stats.total_orders }}</div>
            </div>
            <div class="stat-card">
                <h3>Revenue</h3>
                <div class="value">${{ "%.2f"|format(stats.total_revenue|float) }}</div>
            </div>
            <div class="stat-card">
                <h3>Completed Orders</h3>
                <div class="value">{{ stats.completed_orders }}</div>
            </div>
        </div>

        <div class="section">
            <h2>Products</h2>
            {% if products %}
            <table>
                <thead>
                    <tr><th>ID</th><th>Name</th><th>Description</th><th>Price</th><th>Stock</th></tr>
                </thead>
                <tbody>
                    {% for p in products %}
                    <tr>
                        <td>{{ p.id }}</td>
                        <td>{{ p.name }}</td>
                        <td>{{ p.description }}</td>
                        <td>${{ "%.2f"|format(p.price|float) }}</td>
                        <td>{{ p.stock }}</td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
            {% else %}
            <div class="empty-state">No products available. The database appears to be empty.</div>
            {% endif %}
        </div>

        <div class="section">
            <h2>Recent Orders</h2>
            {% if orders %}
            <table>
                <thead>
                    <tr><th>ID</th><th>Customer</th><th>Date</th><th>Total</th><th>Status</th></tr>
                </thead>
                <tbody>
                    {% for o in orders %}
                    <tr>
                        <td>{{ o.id }}</td>
                        <td>{{ o.customer_name }}</td>
                        <td>{{ o.order_date }}</td>
                        <td>${{ "%.2f"|format(o.total_amount|float) }}</td>
                        <td><span class="status status-{{ o.status }}">{{ o.status }}</span></td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
            {% else %}
            <div class="empty-state">No orders found. The database appears to be empty.</div>
            {% endif %}
        </div>
        {% endif %}
    </div>
</body>
</html>
"""


@app.route("/")
def index():
    backend_healthy = False
    error = None
    stats = {}
    products = []
    orders = []

    try:
        health_resp = requests.get(f"{BACKEND_URL}/api/health", timeout=3)
        if health_resp.status_code == 200:
            backend_healthy = True
    except Exception:
        error = f"Cannot connect to backend at {BACKEND_URL}"
        return render_template_string(HTML_TEMPLATE, backend_healthy=False, error=error,
                                      stats={}, products=[], orders=[], db_empty=False)

    db_empty = False
    try:
        stats_resp = requests.get(f"{BACKEND_URL}/api/stats", timeout=5)
        stats_data = stats_resp.json()
        stats = stats_data.get("stats", {})
        db_empty = stats_data.get("empty", False)

        products_resp = requests.get(f"{BACKEND_URL}/api/products", timeout=5)
        products = products_resp.json().get("products", [])

        orders_resp = requests.get(f"{BACKEND_URL}/api/orders", timeout=5)
        orders = orders_resp.json().get("orders", [])
    except Exception as e:
        error = f"Error fetching data: {str(e)}"

    return render_template_string(HTML_TEMPLATE, backend_healthy=backend_healthy,
                                  error=error, stats=stats, products=products,
                                  orders=orders, db_empty=db_empty)


@app.route("/health")
def health():
    return {"status": "healthy", "service": "frontend"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
