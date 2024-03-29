import os
import json
import redis
import pymysql


## Handler
def lambda_handler(event, context):
    message = "The query was {} !".format(event["query"])
    return {"message": message}


class DB:
    def __init__(self, **params):
        params.setdefault("charset", "utf8mb4")
        params.setdefault("cursorclass", pymysql.cursors.DictCursor)

        self.mysql = pymysql.connect(**params)

    def query(self, sql):
        with self.mysql.cursor() as cursor:
            cursor.execute(sql)
            return cursor.fetchall()

    def record(self, sql, values):
        with self.mysql.cursor() as cursor:
            cursor.execute(sql, values)
            return cursor.fetchone()


# Time to live for cached data
TTL = 10

# Read the Redis credentials from the REDIS_URL environment variable.
REDIS_URL = os.environ.get("REDIS_URL")

# Read the DB credentials from the DB_* environment variables.
DB_HOST = os.environ.get("DB_HOST")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")
DB_NAME = os.environ.get("DB_NAME")

# Initialize the database
Database = DB(host=DB_HOST, user=DB_USER, password=DB_PASS, db=DB_NAME)

# Initialize the cache
Cache = redis.Redis.from_url(REDIS_URL)


def fetch(sql):
    """Retrieve records from the cache, or else from the database."""
    res = Cache.get(sql)
    data = {"result": res, "from": "elasticache"}

    if res:
        return json.loads(data)

    res = Database.query(sql)
    data = {"result": res, "from": "rds"}
    Cache.setex(sql, TTL, json.dumps(res))
    return data


def planet(id):
    """Retrieve a record from the cache, or else from the database."""
    key = f"planet:{id}"
    res = Cache.hgetall(key)

    if res:
        return res

    sql = "SELECT `id`, `name` FROM `planet` WHERE `id`=%s"
    res = Database.record(sql, (id,))

    if res:
        Cache.hmset(key, res)
        Cache.expire(key, TTL)

    return res


def fetch_from_rds(sql):
    """Retrieve records from rds."""

    res = Database.query(sql)
    data = {"result": res, "from": "rds"}
    return data