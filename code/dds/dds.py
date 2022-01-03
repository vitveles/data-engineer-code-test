import psycopg2
import yaml


def start_dds_job():
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
        with open(f'dds/ddl/codm_{target}.ddl') as f:
            ddl = f.read()

        print(ddl)
        cur.execute(ddl)

    # execute etl
    for target in config["targets"]:
        with open(f'dds/etl/codm_{target}.sql') as f:
            ddl = f.read()

        print(ddl)
        cur.execute(ddl)

    conn.commit()
