select
  hc.patient_id ,
  hc.visit_id as "visit id date_of_sample_collected_for_hcv_viral_load",
  hc.hcv_viral_load ,
  hc.hcv_viral_load ~ '\*.*([0-9]{3})' as "VL result numeral format" ,
  hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' as "VL result exponential format" ,
  case
  	when not hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' and hc.hcv_viral_load ~ '\*.*([0-9]{3})' then
  	split_part(hc.hcv_viral_load, '*', 1)::numeric * 10 ^ right(hc.hcv_viral_load,1)::integer
  	when not hc.hcv_viral_load ~ '([⁰¹²³⁴⁵⁶⁷⁸⁹])' and hc.hcv_viral_load ~ '([0-9]{3,5})' then
  	hc.hcv_viral_load::integer
  	end
  as "VL result" ,
  hc.date_of_sample_collected_for_hcv_viral_load ,
  hc2.date_of_daa_termination ,
  hc2.visit_id as "visit id date_of_daa_termination",
  case
    when hc2.date_of_daa_termination is not null then
	extract(year from age(hc.date_of_sample_collected_for_hcv_viral_load::date,hc2.date_of_daa_termination::date))*12 + extract(month from age(hc.date_of_sample_collected_for_hcv_viral_load::date,hc2.date_of_daa_termination::date))
	end
  as "duration_months"
from hepatitis_c hc
left outer join hepatitis_c hc2
  on hc2.patient_id = hc.patient_id
	and hc2.visit_id = (
		select max(hc3.visit_id)
		from hepatitis_c hc3
		where hc3.patient_id = hc2.patient_id and hc3.date_of_daa_termination is not null
	)
where hc.hcv_viral_load is not null
