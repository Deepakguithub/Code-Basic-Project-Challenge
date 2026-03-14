create table dim_com(
campaign_id varchar(30),
campaign_name varchar(30),
start_date date,
end_date date
);

drop table if exists dim_pro
create table dim_pro(
product_code varchar(30),
product_name varchar(50),
category varchar(30)
);

create table dim_sto(
store_id varchar(20),
city varchar(15)
)


drop table if exists fact_evt
create table fact_evt(
event_id varchar(20),
store_id varchar(20),
campaign_id	varchar(20),
product_code varchar(20),	
base_price int,
promo_type varchar(15),
quantity_sold_before_promo int,
quantity_sold_after_promo int
);


select * from fact_evt

select * from dim_pro

select * from dim_sto

select * from dim_com


insert into  dim_com(campaign_id,	campaign_name,	start_date,	end_date)
 values ('CAMP_DIW_01',	'Diwali', '2023-11-12',	'2023-11-18'),
         ('CAMP_SAN_01', 'Sankranti', '2024-01-10',	'2024-01-16')



select * from fact_evt

select * from dim_sto

select store_id,
sum(base_price * quantity_sold_after_promo) - sum(base_price * quantity_sold_before_promo) as incremental_revenue
from fact_evt
group by 1
limit 10;





 


select * from fact_evt

select * from dim_pro

select * from dim_sto

select * from dim_com

select store_id,
sum(quantity_sold_after_promo -quantity_sold_before_promo) as incremental_unit_sold
from fact_evt
group by store_id
order by  incremental_unit_sold  asc
limit 10;



select * from
	(select f.store_id,st. city,
	sum(f.base_price * f.quantity_sold_after_promo)-sum(f.base_price * f.quantity_sold_before_promo) as incremental_revenue
	from fact_evt as f
	join dim_sto as  st
	on f.store_id = st.store_id
	group by f.store_id,st.city
	order by incremental_revenue) as t
order by incremental_revenue desc
	limit 10;


  select 
	    promo_type,
                   sum(
                       case 
			                when promo_type = '500 cashback' 
				      then base_price -500
				            when promo_type = '50% off' 
					  then base_price * 0.5
						    when promo_type = '33% off'
					  then base_price * 0.67
						    when promo_type = '%25 off'
					  then base_price * 0.75
					        when promo_type = 'BOGOF'
					  then base_price * 0.5
							else base_price 
								 end 
								    * 
									  quantity_sold_after_promo
									) 
									 -
  sum(base_price * quantity_sold_before_promo
									     ) as incremental_revenue
  from fact_evt
        group by promo_type
   order by incremental_revenue desc
     limit 2;

									
									
 select 
      promo_type,
             sum(quantity_sold_after_promo 
			              -quantity_sold_before_promo)
			               as incremental_unit_sold
   from fact_evt
     where promo_type in (
            '500 cashback',
			'50% off',
			'33% off',
			'25% off',
			'BOGOF'
			
	)
	group by promo_type
	order by incremental_unit_sold asc
    limit 2;



 select 
      promo_type,
	        avg(sum(base_price * quantity_sold_after_promo) 
			    - sum(base_price * quantity_sold_before_promo)) as avg_performen,
				sum(sum(base_price * quantity_sold_after_promo) 
			    - sum(base_price * quantity_sold_before_promo)) as total_performen
 
       from 
           ( select
		             case 
					     when promo_type in(
            '500 cashback',
			'50% off',
			'33% off',
			'25% off',
			'BOGOF'
			) then 
	'discount' 
	          when promo_type = 'BOGOF' 
	then 'BOGOF' 
	            when promo_type = '500 Cashback' 
	then 'cashback' 
	  end  as promo_type,

	  ( case 
	        when promo_type = '500 
cashback' then base_price -500
              when promo_type = '50% off'
		  then base_price * 0.5
		      when promo_type = '33% off'
		  then base_price * 0.67
		      when promo_type = '25% off'
		  then base_price * 0.75
		      when promo_type = 'BOGOF'
		  then base_price * 0.5
		      end 
			     * quantity_sold_after_promo
			       ) 
				   -
				     (base_price -
quantity_sold_before_promo)
          as incremental_value
		 from fact_evt ) t

	group by promo_type
	order by avg_performenc



select promo_type,
        sum(quantity_sold_after_promo 
	-quantity_sold_before_promo) as incremental_unit,
round(avg(
	     case
		     when promo_type = '25% off' 
		 then  0.25
		     when promo_type = '50% off'
	     then 0.50
		     when promo_type = '33% off'
		 then 0.33
		     when promo_type = 'BOGOF' 
		 then 0.50
		     when promo_type = '500 cashback'
		 then 500.0/base_price
			end  ),2) as avg_discount,

			     round(sum(quantity_sold_after_promo 
			-quantity_sold_before_promo) 
			   /
			avg(
	    case
		     when promo_type = '25% off' 
		then  0.25
		     when promo_type = '50% off'
	    then 0.50
		     when promo_type = '33% off'
		then 0.33
		     when promo_type = 'BOGOF' 
		then 0.50
		     when promo_type = '500 cashback'
		then 500.0/base_price
			end  ),2) as performen_score
	from fact_evt
	  group by promo_type
	  order by performen_score

select * from fact_evt

select * from dim_pro

select * from dim_sto

select * from dim_com


select 
      p.category,
sum(f.quantity_sold_after_promo 
     -f.quantity_sold_before_promo) 
	         as sales_lift
	 from fact_evt as f
	     join
	  dim_pro as p
on f.product_code = p.product_code
group by p.category
order by sales_lift desc


select * from
(select 
       p.product_code,
	   p.product_name,
	   p.category,
sum(f.quantity_sold_after_promo 
      -f.quantity_sold_before_promo) 
	        as sales_lift
 from 
    dim_pro as p
 join
    fact_evt as f
 on p.product_code = f.product_code
 group by 1,2,3
 order by sales_lift desc) t
 order by sales_lift desc
 limit 5;



			 
select * from
(select 
       p.product_code,
	   p.product_name,
	   p.category,
sum(f.quantity_sold_after_promo 
      -f.quantity_sold_before_promo) 
	        as sales_lift
 from 
    dim_pro as p
 join
    fact_evt as f
 on p.product_code = f.product_code
 group by 1,2,3
 order by sales_lift desc) t
 order by sales_lift asc
 limit 5;






with cts as
(select p.category,
f.quantity_sold_after_promo 
      -f.quantity_sold_before_promo
	       as sales_lift,
	   case
		     when f.promo_type = '25% off' 
		then  0.25
		     when f.promo_type = '50% off'
	    then 0.50
		     when f.promo_type = '33% off'
		then 0.33
		     when f.promo_type = 'BOGOF' 
		then 0.50
		     when f.promo_type = '500 cashback'
		then 500.0/f.base_price
			end   as discount_promo
   from fact_evt as f
        join
		dim_pro as p
	on f.product_code = p.product_code) 
  select category,       
	     corr(discount_promo, sales_lift)
		         as correletion_value
  from cts
       group by category
