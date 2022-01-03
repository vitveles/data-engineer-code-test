from stage.stage import start_stage_job
from keys.keys import start_keys_job
from dds.dds import start_dds_job
from datamart.datamart import start_datamart_job


def start_job():
    start_stage_job()
    start_keys_job()
    start_dds_job()
    start_datamart_job()


start_job()
