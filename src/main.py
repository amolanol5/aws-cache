import os
import json
import redis
import time
import pymysql
import datetime


## Handler
def lambda_handler(event, context):
    #query from event
    parsed_event = json.loads(event["body"])
    query = parsed_event["query"]
    print(query)
    
    #data from elasticache or rds
    fetch_data = fetch(query)
    print(fetch_data)
    
    #add time
    is_date = datetime.datetime.now()
    now = is_date.time()
    res = fetch_data | {"Time": str(now)}
    
    return res

    
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
TTL = 30

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
    inicio = time.time()
    """Retrieve records from the cache, or else from the database."""
    res = Cache.get(sql)

    if res:
        fin = time.time()
        tiempo_total_ms = (fin - inicio) * 1000
        return {"query_result" : json.loads(res), "A_from" : "Elasticache" , "Tiempo_Ejecucion" : tiempo_total_ms} 

    res = Database.query(sql)
    fin = time.time()
    tiempo_total_ms = (fin - inicio) * 1000
    
    #saving response in cache
    Cache.setex(sql, TTL, json.dumps(res))
    
    return {"query_result" : res, "A_from" : "RDS", "Tiempo_Ejecucion" : tiempo_total_ms}


# def planet(id):
#     """Retrieve a record from the cache, or else from the database."""
#     key = f"planet:{id}"
#     res = Cache.hgetall(key)

#     if res:
#         return res

#     sql = "SELECT `id`, `name` FROM `planet` WHERE `id`=%s"
#     res = Database.record(sql, (id,))

#     if res:
#         Cache.hmset(key, res)
#         Cache.expire(key, TTL)

#     return res
