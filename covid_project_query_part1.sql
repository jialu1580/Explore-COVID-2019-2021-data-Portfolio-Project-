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
group by location,population    ------����group by location����population�����У�Ҫ����һ�������У���Ϊpopulation���ݹ������ģ���ͬ������һ���ظ�һ�����ֵ�
order by percentangepopulationinfection desc

-----3.tableau view
create view table3 as
select location,population,Max(total_cases)as hightestinfectioncount, MAX((total_cases/population))*100 as percentangepopulationinfection
from CovidDeaths
group by location,population    ------����group by location����population�����У�Ҫ����һ�������У���Ϊpopulation���ݹ������ģ���ͬ������һ���ظ�һ�����ֵ�

-----4.tableau
create view table4 as
select location,population,date,Max(total_cases)as hightestinfectioncount, MAX((total_cases/population))*100 as percentangepopulationinfection
from CovidDeaths
group by location,population,date
---order by percentangepopulationinfection desc

-----showing the countries with the highest death population
select location,Max(cast(total_deaths as int))as hightesdeathcount-----��Ϊtotal daeth ����int,Ҫ��ת����int
from CovidDeaths
where continent is not null
group by location  

order by hightesdeathcount desc



--------check by contient------���ų�һЩ�ط���-��ѯ���Ľ�����ǵ��ս�������������ܺͳ�������
select location, sum(cast(total_deaths as int))as totaldeathcount-----��Ϊtotal daeth ����int,Ҫ��ת����int
from CovidDeaths
where continent is null
and location   not in ('world','European Union','International')
group by location 

order by totaldeathcount desc
------2.tableau view 
create view everycontinenttotaldeathcount as
select location, sum(cast(total_deaths as int))as totaldeathcount-----��Ϊtotal daeth ����int,Ҫ��ת����int
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
---order by 1,2 ��������ػ����

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



-----looking popultation vs total vaccine------ÿ������������������ͣ�����ǰһ����ܺͣ�

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths dea
join Covidvaccine vac
on dea.location =vac.location
and dea.date=vac.date


---use cte (���ñ���ʽ,����Ƭ�Σ�����ʱ��������©Ҫ���ñ�����ԣ�

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



------temp table (���´���һ����
drop table if exists #populationvaccine------������β�ѯ�½����ֲ���ÿ������ɾ��
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


