import psycopg2
import yaml


def start_keys_job():
    with open('connections.yaml') as f:
        connections = yaml.safe_load(f)

    with open('config.yaml') as f:
        config = yaml.safe_load(f)

    conn = connections["postgr"]
    conn = psycopg2.connect(
        f"host={conn['host']} dbname={conn['dbname']} user={conn['user']} password={conn['password']}")

    cur = conn.cursor()

    # create ddl
    for target in config["targets"]:
        with open(f'keys/ddl/k_{target}.ddl') as f:
            ddl = f.read()

        print(ddl)
        cur.execute(ddl)

    # insert keys
    for target in config["targets"]:
        with open(f'keys/etl/k_{target}.sql') as f:
            sql = f.read()

        print(sql)
        cur.execute(sql)

    conn.commit()
