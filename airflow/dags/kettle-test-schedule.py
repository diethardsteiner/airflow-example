from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2020, 3, 1),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG('KettlePrintLog', default_args=default_args, schedule_interval=timedelta(days=1))

t1 = BashOperator(
    task_id='KettleWriteToLog',
    bash_command='/Users/diethardsteiner/apps/pdi-ce-8.2/kitchen.sh -file=/Users/diethardsteiner/git/airflow-example/pdi/jobs-and-transformations/job-write-to-log.kjb',
    dag=dag)