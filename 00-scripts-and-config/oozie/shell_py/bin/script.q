select count(*), id from dim_aisle group by id having count(*) > 1 limit 5;
select count(*), order_id from fact_order group by order_id having count(*) > 1 limit 5;
select count(*), department_id from dim_department group by department_id having count(*) > 1 limit 5;
select count(*), product_id from dim_product group by product_id having count(*) > 1 limit 5;

insert overwrite table dim_aisle select id, aisle_name, insert_dttm, insert_by  from (select id, aisle_name, insert_dttm, insert_by, row_number() over(partition by id order by insert_dttm desc) rn from dim_aisle) x where rn =1;

select count(*), id from dim_aisle group by id having count(*) > 1 limit 5;

insert overwrite table fact_order select order_id, user_id, order_number, order_hour_of_day, days_since_prior_order, order_date, insert_dttm, insert_by  from (select order_id, user_id, order_number, order_hour_of_day, days_since_prior_order, order_date, insert_dttm, insert_by, row_number() over(partition by order_id order by insert_dttm desc) rn from fact_order) x where rn =1;

select count(*), order_id from fact_order group by order_id having count(*) > 1 limit 5;

insert overwrite table dim_department select department_id, department, insert_dttm, insert_by  from (select department_id, department, insert_dttm, insert_by, row_number() over(partition by department_id order by insert_dttm desc) rn from dim_department) x where rn =1;

select count(*), department_id from dim_department group by department_id having count(*) > 1 limit 5;

insert overwrite table dim_product select product_id, product_name, aisle_id, department_id, insert_dttm, insert_by  from (select product_id, product_name, aisle_id, department_id, insert_dttm, insert_by, row_number() over(partition by product_id order by insert_dttm desc) rn from dim_product) x where rn =1;

select count(*), product_id from dim_product group by product_id having count(*) > 1 limit 5;
