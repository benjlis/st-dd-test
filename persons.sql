SELECT nspname AS schema_name, relname AS table_name
    FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'r' AND 
          nspname NOT IN ('pg_catalog', 'pg_toast', 'foiarchive') AND
          relname = 'persons';

-- select 'select count(*) from ' || nspname || '.' || relname || ';'
-- select 'select full_name from ' || nspname || '.' || relname || ' union '
-- select  'select ''' || replace(nspname, 'declassification_', '') ||
--         ''', (select count(*) from ' || nspname || '.' || relname || ')' ||
--         ', (select count(*) from ' || nspname || '.' || substr(relname, 1, length(relname)-1) || '_doc) union'
select 'select p.name, p.id, ''' || replace(nspname, 'declassification_', '') || ''', count(*) from ' || 
       nspname || '.' || relname || '  p join ' || nspname || '.' || substr(relname, 1, length(relname)-1) || 
       '_doc pd on p.id = pd.person_id group by 1, 2, 3 union '
    from pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'r' AND 
          nspname NOT IN ('pg_catalog', 'pg_toast', 'foiarchive') AND
          relname = 'persons';

create view persons_temp (person) as
select name || ' (frus)' from declassification_frus.persons union 
 select encode(name, 'escape') || ' (clinton)' from declassification_clinton.persons union 
 select name::text || ' (cables)' from declassification_cables.persons union 
 select encode(name, 'escape') || ' (kissinger)' from declassification_kissinger.persons union 
 select name || ' (briefing)' from briefing.persons union 
 select name::text || ' (cia)' from declassification_cia.persons union 
 select name::text || ' (ddrs)' from declassification_ddrs.persons union 
 select name::text || ' (worldbank)' from declassification_worldbank.persons union 
 select name::text || ' (cpdoc)' from declassification_cpdoc.persons union 
 select name::text || ' (cabinet)' from declassification_cabinet.persons
 order by 1;

 \copy (select * from persons_temp) to 'persons.csv' with csv

create view person_corpora_summary_temp(corpus, person_cnt, person_reference_cnt) AS
select 'frus', (select count(*) from declassification_frus.persons), (select count(*) from declassification_frus.person_doc) union
 select 'clinton', (select count(*) from declassification_clinton.persons), (select count(*) from declassification_clinton.person_doc) union
 select 'cables', (select count(*) from declassification_cables.persons), (select count(*) from declassification_cables.person_doc) union
 select 'kissinger', (select count(*) from declassification_kissinger.persons), (select count(*) from declassification_kissinger.person_doc) union
 select 'briefing', (select count(*) from briefing.persons), (select count(*) from briefing.person_doc) union
 select 'cia', (select count(*) from declassification_cia.persons), (select count(*) from declassification_cia.person_doc) union
 select 'ddrs', (select count(*) from declassification_ddrs.persons), (select count(*) from declassification_ddrs.person_doc) union
 select 'worldbank', (select count(*) from declassification_worldbank.persons), (select count(*) from declassification_worldbank.person_doc) union
 select 'cpdoc', (select count(*) from declassification_cpdoc.persons), (select count(*) from declassification_cpdoc.person_doc) union
 select 'cabinet', (select count(*) from declassification_cabinet.persons), (select count(*) from declassification_cabinet.person_doc) union
 select 'un', 0, 0 union
 select 'nato', 0, 0;

 \copy (select * from person_corpora_summary_temp order by corpus) to 'person_corpora_summary.csv' with csv header

select p.name, p.id, count(*)
from declassification_frus.persons p join declassification_frus.person_doc pd on p.id = pd.person_id
group by p.name, p.id;

create view person_corpora_detailed_temp(person, id, corpus, reference_cnt) as
select p.name, p.id::text, 'frus', count(pd.person_id) from declassification_frus.persons  p left join declassification_frus.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select encode(p.name, 'escape'), p.id::text, 'clinton', count(pd.person_id) from declassification_clinton.persons  p left join declassification_clinton.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'cables', count(pd.person_id) from declassification_cables.persons  p left join declassification_cables.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select encode(p.name, 'escape'), p.id::text, 'kissinger', count(pd.person_id) from declassification_kissinger.persons  p left join declassification_kissinger.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'briefing', count(pd.person_id) from briefing.persons  p left join briefing.person_doc pd on p.id::text = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'cia', count(pd.person_id) from declassification_cia.persons  p left join declassification_cia.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union
 select p.name, p.id::text, 'ddrs', count(pd.person_id) from declassification_ddrs.persons  p left join declassification_ddrs.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'worldbank', count(pd.person_id) from declassification_worldbank.persons  p left join declassification_worldbank.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'cpdoc', count(pd.person_id) from declassification_cpdoc.persons  p left join declassification_cpdoc.person_doc pd on p.id = pd.person_id group by 1, 2, 3 union 
 select p.name, p.id::text, 'cabinet', count(pd.person_id) from declassification_cabinet.persons  p left join declassification_cabinet.person_doc pd on p.id = pd.person_id group by 1, 2, 3;

\copy (select * from person_corpora_detailed_temp order by person, corpus) to 'person_corpora_detailed.csv' with csv header




 with c (select corpus::text from foiarchive.corpora union select 'ddrs'),
      
 select corpus from foiarchive.corpora;