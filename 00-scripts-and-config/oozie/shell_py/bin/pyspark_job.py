#pyspark_job

from pyspark.sql import SparkSession
from pyspark import SparkConf, SparkContext,SQLContext
spark = SparkSession.builder.appName("retail-data-lake-migration").enableHiveSupport().getOrCreate()
spark.conf.set('mapreduce.input.fileinputformat.input.dir.recursive','true')

spark.sql('''alter table aisles set tblproperties ("skip.header.line.count"="1")''')
spark.sql('''alter table orders set tblproperties ("skip.header.line.count"="1")''')
spark.sql('''alter table products set tblproperties ("skip.header.line.count"="1")''')
spark.sql('''alter table departments set tblproperties ("skip.header.line.count"="1")''')

df = spark.sql('''select *,current_timestamp() insert_dttm ,'Pyspark' insert_by from aisles where aisle_id is not null''')
df.write.mode('append').insertInto('dim_aisle')

spark.sql('''SELECT order_number, user_id,DSPO DAYS_SINCE_PRIOR_ORDER, DATE_ADD('2022-01-01', cast (nvl(ORDER_DAYS,0) as int)) ORDER_DATE  FROM ( SELECT order_id,order_number, user_id, DAYS_SINCE_PRIOR_ORDER DSPO, SUM(DAYS_SINCE_PRIOR_ORDER) OVER(PARTITION BY USER_ID ORDER BY ORDER_NUMBER) ORDER_DAYS FROM ORDERS where order_id is not null) X''').createOrReplaceTempView('orders_framed')
df2 = spark.sql('''select order_id, or.user_id,or.order_number,or.order_hour_of_day,or.DAYS_SINCE_PRIOR_ORDER, ORDER_DATE,current_timestamp() insert_dttm,'Pyspark' insert_by from orders or join orders_framed or_fr on or.user_id=or_fr.user_id and or.order_number=or_fr.order_number where order_id is not null order by user_id,order_number''')
df2.write.mode('append').insertInto('fact_order')

df3 = spark.sql('''select * , current_timestamp() insert_dttm, 'Pyspark' insert_by from products where product_id is not null''')
df3.write.mode('append').insertInto('dim_product')

df4 = spark.sql('''select *, current_timestamp() insert_dttm, 'Pyspark' insert_by from departments where department_id is not null''')
df4.write.mode('append').insertInto('dim_department')

#spark.sql('''select * from dim_aisle order by id limit 10''').show()
#spark.sql('''select * from fact_order order by user_id limit 10''').show()
#spark.sql('''select * from dim_product order by product_id limit 10''').show()
#spark.sql('''select * from dim_department order by department_id limit 10''').show()
