SELECT *
FROM PortfolioProject..CovidDeaths
order BY 3,4

/*SELECT *
FROM PortfolioProject..CovidVaccinations
order BY 3,4*/

--select date that we will be using
SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order BY 1,2

--looking at total cases vs. total deaths
--shows what percentage of population got Covid 19
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order BY 1,2

--looking at total cases vs. population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order BY PercentPopulationInfected DESC

--breakdown by continent
SELECT continent, max(total_deaths) as totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order BY totaldeathcount DESC

--showing countries with the highest death count per population
SELECT location, max(total_deaths) as totaldeathcount
FROM PortfolioProject..CovidDeaths
where continent is null
group by location
order BY totaldeathcount DESC

--global numbers
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
order BY 1,2

select *
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date)
as RollingVaccinationCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as (
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date)
as RollingVaccinationCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, cast(RollingVaccinationCount as float)/population *100
from PopVsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date)
as RollingVaccinationCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

SELECT *, cast(RollingVaccinationCount as float)/population *100
from #PercentPopulationVaccinated

--creating view to store data for later visualization
create view PercentPopulationVaccinated 
as select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date)
as RollingVaccinationCount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated