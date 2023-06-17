select *
from p1.. deaths
where continent is not null
order by 3,4

--select *
--from p1.. vax
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from p1.. deaths
where continent is not null
order by 1,2


-- Total cases Vs. Total deaths

select location, date, total_cases, total_deaths, (cast(total_deaths as numeric)) / (cast(total_cases as numeric))*100 as deathpercentage
from p1.. deaths
where location like '%lanka%'
order by 1,2

-- Total cases vs population

select location, date, total_cases, population, (cast(total_cases as numeric)) / (cast(population as numeric))*100 as covidpercentage
from p1.. deaths
where location like '%lanka%'
order by 1,2

--heightest infection vs population
select location, population, max(total_cases) as heighestinfectioncount, population, 
max(cast(total_cases as numeric)) / (cast(population as numeric))*100 as populationinfectedpercentage
from p1.. deaths
where continent is not null
group by location, population
order by populationinfectedpercentage desc

--countries with the heightest deathcount per population

select location, population, max(cast(total_deaths as int)) as totaldeathcount
from p1.. deaths
where continent is not null
group by location, population
order by  totaldeathcount desc

-- by continent
select continent, max(cast(total_deaths as int)) as totaldeathcount
from p1.. deaths
where continent is not null
group by continent
order by  totaldeathcount desc

--Global death number
SET ANSI_WARNINGS on
SET ARITHABORT OFF

select sum(cast(total_cases as numeric)) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as numeric))/ sum(cast(new_cases as numeric))*100 as globaldeaths
from p1.. deaths
where continent is not null
--group by date
order by 1,2

--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date)
as peoplevaccinated
--, (peoplevaccinated/population)*100
from p1.. deaths dea
join p1.. vax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with PopvsVac (continent, location, date, population, new_vaccination, peoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date)
as peoplevaccinated
--, (peoplevaccinated/population)*100
from p1.. deaths dea
join p1.. vax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* , (peoplevaccinated/ population)* 100
from popvsVac


--temp table

drop table if exists #populationvaccinated
create table #populationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
peoplevaccinated numeric
)

insert into #populationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date)
as peoplevaccinated
--, (peoplevaccinated/population)*100
from p1.. deaths dea
join p1.. vax vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (peoplevaccinated/population)*100
from #populationvaccinated

--creating a viewpoint

create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date)
as peoplevaccinated
--, (peoplevaccinated/population)*100
from p1.. deaths dea
join p1.. vax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from percentagepopulationvaccinated