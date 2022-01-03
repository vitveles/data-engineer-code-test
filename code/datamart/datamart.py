import psycopg2
import yaml


def start_datamart_job():
    with open('connections.yaml') as f:
        connections = yaml.safe_load(f)

    with open('config.yaml') as f:
        config = yaml.safe_load(f)

    conn = connections["postgr"]
    conn = psycopg2.connect(
        f"host={conn['host']} dbname={conn['dbname']} user={conn['user']} password={conn['password']}")

    cur = conn.cursor()

    # create execute dm scripts
    for dmn, dm in config["datamarts"].items():
        for script in dm:
            with open(f'datamart/etl/{script}.sql') as f:
                scr = f.read()

            print(scr)
            cur.execute(scr)

    conn.commit()
