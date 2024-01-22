select * from CoronaStat.dbo.CovidDeaths
order by 3,4

--select * from CoronaStat.dbo.CovidVaccinations
--order by 3,4

select  location,date,total_cases,new_cases,total_deaths, population
from CoronaStat.dbo.CovidDeaths
order by 1,2

--loocking at total cases vs total deaths


select  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from CoronaStat.dbo.CovidDeaths
where location like 'tu%'
order by 1,2


--loocking at total cases vs  population


select  location,date,total_cases,population ,(total_cases/population)*100 as percentagePop
from CoronaStat.dbo.CovidDeaths
where location like 'tu%'
order by 1,2

--highest country has infection rate

select location,population,max(total_cases)as highesttotalCases ,max(total_cases/population)*100 as percentageO
from CoronaStat.dbo.CovidDeaths
group by location,population
Order by percentageO desc

--highest continent death rate

select continent,max(cast (total_deaths as int))as totaldeaths 
from CoronaStat.dbo.CovidDeaths
where continent is not null
group by continent
Order by totaldeaths desc

--global deaths 

select location,max(cast (total_deaths as int))as totaldeaths 
from CoronaStat.dbo.CovidDeaths
group by location
Order by totaldeaths desc

-- global daily cases

select  date,sum(new_cases)as totalcases,sum(cast(new_deaths as int))as totaldeaths
from CoronaStat.dbo.CovidDeaths
where continent is not null
group by date
Order by date desc

-- total vaccinations vs population

SELECT dea.continent,dea.location ,dea.date,dea.population,vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as total_vacc
from CoronaStat..CovidDeaths dea
join CoronaStat..CovidDeaths vacc
on dea.location = vacc.location and dea.date =vacc.date
where dea.continent is not null
order by 2,3



--cte usage

with Popvsvacc (continent,location,date,population,new_vaccinations,total_vacc)
as
(
SELECT dea.continent,
dea.location ,
dea.date,
dea.population,
vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vacc

from CoronaStat..CovidDeaths dea
join CoronaStat..CovidDeaths vacc
	on dea.location = vacc.location and dea.date =vacc.date
	where dea.continent is not null
--order by 2,3
)
select *,(total_vacc/population)*100 as Percenta from Popvsvacc


--temp table 

drop table if exists #temppercen

create table #temppercen
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacc numeric,
total_vacc numeric,
)

insert into #temppercen
SELECT dea.continent,
dea.location ,
dea.date,
dea.population,
vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vacc

from CoronaStat..CovidDeaths dea
join CoronaStat..CovidDeaths vacc
	on dea.location = vacc.location and dea.date =vacc.date
	where dea.continent is not null

select *,(total_vacc/population)*100 as percentageO
from #temppercen

--create view for later visualisation

Create View PercenPopulationVacc as 

SELECT dea.continent,
dea.location ,
dea.date,
dea.population,
vacc.new_vaccinations,
sum(convert(int,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vacc

from CoronaStat..CovidDeaths dea
join CoronaStat..CovidDeaths vacc
	on dea.location = vacc.location and dea.date =vacc.date
	where dea.continent is not null


select *
from PercenPopulationVacc

