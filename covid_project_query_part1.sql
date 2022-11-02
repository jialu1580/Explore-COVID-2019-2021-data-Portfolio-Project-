select *
from CovidDeaths
order by 3,4


--select *
--from Covidvaccine
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

----looks at total case vs total death 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentange
from CovidDeaths
where location ='china' 
order by 1,2

---------looks at total case vs population
----shows what percentage population got covid 
select location,population,total_cases, (total_cases/population)*100 as percentangepopulationinfection
from CovidDeaths
where continent is not null
---where location like 'china'
order by 1,2


--------looks  countries with the hightest infection rate compare to population
select location,population,Max(total_cases)as hightestinfectioncount, MAX((total_cases/population))*100 as percentangepopulationinfection
from CovidDeaths
group by location,population    ------单独group by location或者population都不行，要两个一起分类才行，因为population根据国家来的，相同国家是一种重复一个数字的
order by percentangepopulationinfection desc

-----3.tableau view
create view table3 as
select location,population,Max(total_cases)as hightestinfectioncount, MAX((total_cases/population))*100 as percentangepopulationinfection
from CovidDeaths
group by location,population    ------单独group by location或者population都不行，要两个一起分类才行，因为population根据国家来的，相同国家是一种重复一个数字的

-----4.tableau
create view table4 as
select location,population,date,Max(total_cases)as hightestinfectioncount, MAX((total_cases/population))*100 as percentangepopulationinfection
from CovidDeaths
group by location,population,date
---order by percentangepopulationinfection desc

-----showing the countries with the highest death population
select location,Max(cast(total_deaths as int))as hightesdeathcount-----因为total daeth 不是int,要先转化成int
from CovidDeaths
where continent is not null
group by location  

order by hightesdeathcount desc



--------check by contient------（排除一些地方）-查询出的结果都是单日结果，不是所有总和出来的数
select location, sum(cast(total_deaths as int))as totaldeathcount-----因为total daeth 不是int,要先转化成int
from CovidDeaths
where continent is null
and location   not in ('world','European Union','International')
group by location 

order by totaldeathcount desc
------2.tableau view 
create view everycontinenttotaldeathcount as
select location, sum(cast(total_deaths as int))as totaldeathcount-----因为total daeth 不是int,要先转化成int
from CovidDeaths
where continent is null
and location   not in ('world','European Union','International')
group by location 


-----golbal numbers per day
select date, sum(new_cases) as totalcasescount,sum(cast (new_deaths  as int)) as totaldeathscount, sum(cast (new_deaths  as int))/sum(new_cases) *100 as percentangepopulationinfection
from CovidDeaths
where continent is not null
group by date
order by 1,2


-----creat view for golbal numbers per day
create view golbalnumbersperday as
select date, sum(new_cases) as totalcasescount,sum(cast (new_deaths  as int)) as totaldeathscount, sum(cast (new_deaths  as int))/sum(new_cases) *100 as percentangepopulationinfection
from CovidDeaths
where continent is not null
group by date
---order by 1,2 如果不隐藏会出错

select* 
from golbalnumbersperday


-----golbal numbers 
select  sum(new_cases) as totalcasescount,sum(cast (new_deaths  as int)) as totaldeathscount, sum(cast (new_deaths  as int))/sum(new_cases) *100 as percentangepopulationinfection
from CovidDeaths
where continent is not null
---group by date
order by 1,2


------1.tableau view
create view golbalnumber as
select  sum(new_cases) as totalcasescount,sum(cast (new_deaths  as int)) as totaldeathscount, sum(cast (new_deaths  as int))/sum(new_cases) *100 as percentangepopulationinfection
from CovidDeaths
where continent is not null



-----looking popultation vs total vaccine------每天打疫苗数增加总数和（加上前一天的总和）

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths dea
join Covidvaccine vac
on dea.location =vac.location
and dea.date=vac.date


---use cte (公用表表达式,引用片段）引用时，不能遗漏要引用表的属性）

with populationvsvaccine(continent,location ,date,population,new_vaccinations,RollingpeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths dea
join Covidvaccine vac
on dea.location =vac.location
and dea.date=vac.date)

select *,(RollingpeopleVaccinated/population) * 100 
from populationvsvaccine



------temp table (重新创建一个表）
drop table if exists #populationvaccine------如果想多次查询新建表又不想每次重新删除
create table #populationvaccine
(continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric)

insert into #populationvaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths dea
join Covidvaccine vac
on dea.location =vac.location
and dea.date=vac.date
order by 1,2
select *,(RollingpeopleVaccinated/population) * 100  as percentofrollingpeople
from #populationvaccine




--------creating view for store data for later teableau
create view populationvaccine as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths dea
join Covidvaccine vac
on dea.location =vac.location
and dea.date=vac.date


select *
from populationvaccine


