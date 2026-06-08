import os
import logging
from flask import Flask, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST", "database")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "appdb")
DB_USER = os.environ.get("DB_USER", "appuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "apppassword")


def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            cursor_factory=RealDictCursor,
        )
        return conn
    except psycopg2.OperationalError as e:
        logger.error(f"Unable to reach database at {DB_HOST}:{DB_PORT}/{DB_NAME} - {e}")
        raise


def init_db():
    """Create tables if they don't exist. Data seeding is handled separately."""
    logger.info(f"Attempting to connect to database at {DB_HOST}:{DB_PORT}/{DB_NAME}...")
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
        )
    except psycopg2.OperationalError as e:
        logger.error(f"Unable to reach database at {DB_HOST}:{DB_PORT}/{DB_NAME} - {e}")
        raise
    logger.info("Database connection established successfully.")
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            price DECIMAL(10, 2) NOT NULL,
            stock INTEGER NOT NULL DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS orders (
            id SERIAL PRIMARY KEY,
            customer_name VARCHAR(255) NOT NULL,
            order_date DATE NOT NULL DEFAULT CURRENT_DATE,
            total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
            status VARCHAR(50) NOT NULL DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS order_items (
            id SERIAL PRIMARY KEY,
            order_id INTEGER REFERENCES orders(id),
            product_id INTEGER REFERENCES products(id),
            quantity INTEGER NOT NULL,
            unit_price DECIMAL(10, 2) NOT NULL
        );
    """)
    cur.close()
    conn.close()
    logger.info("Database tables initialized successfully.")


with app.app_context():
    try:
        init_db()
    except Exception as e:
        logger.warning(f"Could not initialize database tables: {e}")
        logger.warning("The backend will start but database operations will fail until the database is reachable.")


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "backend"})


@app.route("/api/products", methods=["GET"])
def get_products():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, description, price, stock FROM products ORDER BY id")
        products = cur.fetchall()
        cur.close()
        conn.close()
        if not products:
            return jsonify({"products": [], "empty": True, "message": "No products found. The database may not contain any data yet."})
        return jsonify({"products": products, "empty": False})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/orders", methods=["GET"])
def get_orders():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            SELECT o.id, o.customer_name, o.order_date, o.total_amount, o.status,
                   json_agg(json_build_object(
                       'product_id', oi.product_id,
                       'quantity', oi.quantity,
                       'unit_price', oi.unit_price
                   )) as items
            FROM orders o
            LEFT JOIN order_items oi ON o.id = oi.order_id
            GROUP BY o.id, o.customer_name, o.order_date, o.total_amount, o.status
            ORDER BY o.order_date DESC
        """)
        orders = cur.fetchall()
        cur.close()
        conn.close()
        if not orders:
            return jsonify({"orders": [], "empty": True, "message": "No orders found. The database may not contain any data yet."})
        return jsonify({"orders": orders, "empty": False})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/stats", methods=["GET"])
def get_stats():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            SELECT
                (SELECT COUNT(*) FROM products) as total_products,
                (SELECT COUNT(*) FROM orders) as total_orders,
                (SELECT COALESCE(SUM(total_amount), 0) FROM orders) as total_revenue,
                (SELECT COUNT(*) FROM orders WHERE status = 'completed') as completed_orders
        """)
        stats = cur.fetchone()
        cur.close()
        conn.close()
        is_empty = (stats["total_products"] == 0 and stats["total_orders"] == 0)
        return jsonify({
            "stats": stats,
            "empty": is_empty,
            "message": "Database is empty. No products or orders have been loaded." if is_empty else None
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
