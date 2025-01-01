import yaml
import pyspark
from pyspark.sql import SparkSession

def create_spark_session(app_name, str)->SparkSession: 
    
    with open("environment.yaml","r") as file_object:
        documents=yaml.safe_load_all(file_object)
        for doc in documents:
            doc_name = doc['document_name']
            if doc_name=='iceberg_env':
                CATALOG_URI = doc['catalog_uri'] # Nessie Server URI
                WAREHOUSE = doc['warehouse']     # Minio Address to Write to
                STORAGE_URI = doc['storage_uri'] # Minio IP address from docker inspec


    # Configure Spark with necessary packages and Iceberg/Nessie settings
    conf = (
        pyspark.SparkConf()
            # Include necessary packages
            .set('spark.jars.packages',
                 'org.postgresql:postgresql:42.7.3,'
                 'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.5.0,'
                 'org.projectnessie.nessie-integrations:nessie-spark-extensions-3.5_2.12:0.77.1,'             
                 # awssdk 2.29.42 compatible with spark 3.5.4
                 'software.amazon.awssdk:bundle:2.29.42,'
                 'software.amazon.awssdk:url-connection-client:2.29.42')
            # Enable Iceberg and Nessie extensions
            .set('spark.sql.extensions', 
                 'org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,'
                 'org.projectnessie.spark.extensions.NessieSparkSessionExtensions')
            # Configure Nessie catalog
            .set('spark.sql.catalog.nessie', 'org.apache.iceberg.spark.SparkCatalog')
            .set('spark.sql.catalog.nessie.uri', catalog_uri)
            .set('spark.sql.catalog.nessie.ref', 'main')
            .set('spark.sql.catalog.nessie.authentication.type', 'NONE')
            .set('spark.sql.catalog.nessie.catalog-impl', 'org.apache.iceberg.nessie.NessieCatalog')
            # Set Minio as the S3 endpoint for Iceberg storage
            .set('spark.sql.catalog.nessie.s3.endpoint', storage_uri)
            .set('spark.sql.catalog.nessie.warehouse', warehouse)
            .set('spark.sql.catalog.nessie.io-impl', 'org.apache.iceberg.aws.s3.S3FileIO')
            # Set master location, the job will be sent to the cluster
            .set('spark.master', 'spark://172.33.0.30:7077')  
    )   
    
    # Start Spark session
    spark_session = SparkSession\
            .builder\
            .config(conf=conf)\
            .appName(app_name)\
            .getOrCreate()  

    return spark_session
