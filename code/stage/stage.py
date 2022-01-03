import yaml
from pyspark.sql import SparkSession
from pyspark.sql.functions import lit, col, to_date
from pyspark.sql.types import StructType, StructField, StringType


def start_stage_job():
    with open('connections.yaml') as f:
        connections = yaml.safe_load(f)

    with open('config.yaml') as f:
        config = yaml.safe_load(f)

    conn = connections["postgr"]

    spark = SparkSession \
        .builder \
        .config("spark.jars", "postgresql-42.2.18.jar") \
        .getOrCreate()

    df = spark.createDataFrame(
        [(config["report_date"],), ],
        ["report_date"]
    )

    df.write.option("truncate", "true") \
        .format('jdbc').options(
        url=f"jdbc:postgresql://{conn['host']}:{conn['port']}/{conn['dbname']}",
        driver='org.postgresql.Driver',
        dbtable=f'stg_report_date',
        user=conn['user'],
        password=conn['password']).mode('overwrite').save()

    for source_file in config["sources"]:
        df = spark.read.format("csv").option("header", "true").load(f"/data/{source_file}.csv")
        df = df.withColumn('report_date', to_date(lit(config["report_date"])))

        df.write.option("truncate", "true") \
            .format('jdbc').options(
            url=f"jdbc:postgresql://{conn['host']}:{conn['port']}/{conn['dbname']}",
            driver='org.postgresql.Driver',
            dbtable=f'stg_{source_file}',
            user=conn['user'],
            password=conn['password']).mode('overwrite').save()
