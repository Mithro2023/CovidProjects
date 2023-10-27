select *
from coviddeaths
where continent is not null;

-- -- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- -- looking at total cases vs total death
-- -- showa likely of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from coviddeaths;
-- where location like '%africa%'

-- -- looking at the total case vs population
-- -- What percentages of population got covid
select location, date, population, total_cases, (total_cases/population) * 100 as Deathpercentage
from coviddeaths;
-- where location like '%africa%'

-- -- looking at country with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
from coviddeaths
-- where location like '%africa%'
group by location, population
order by PercentPopulationInfected desc;

-- -- Countries with highest death count per population
select location, continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
group by location, continent
order by TotalDeathCount desc;

-- -- let's break things down by continent
-- -- showing continent with highest death count per population
-- -- (we are missing some of the countries so it's not the actual number)
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- -- Global numbers
select date, sum(new_cases) as Total_cases, sum(total_deaths) as Total_death, sum(total_deaths)/sum(new_cases)*100 DeathPerPercentage
from coviddeaths
where continent is not null
group by date;

-- -- Global Total death
select sum(new_cases) as Total_cases, sum(total_deaths) as Total_death, sum(total_deaths)/sum(new_cases)*100 DeathPerPercentage
from coviddeaths
where continent is not null;

-- -- looking at total population vs vaccination
select 
	de.continent,
    de.location,
    de.date,
    de.population,
    va.total_vaccinations
from coviddeaths de
join covidvaccinations va
	on de.location = va.location
    and de.date = va.date
where de.continent is not null;

-- --Find RollingPeopleVa
select 
	de.continent,
    de.location,
    de.date,
    de.population,
    va.total_vaccinations,
    sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as RollingPeopleVa
from coviddeaths de
join covidvaccinations va
	on de.location = va.location
    and de.date = va.date
where de.continent is not null;

-- -- Use CTE
with PopvsVa (continent, location, date, population, total_vaccinations, RollingPeopleVa)
as
(
	select 
	de.continent,
    de.location,
    de.date,
    de.population,
    va.total_vaccinations,
    sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as RollingPeopleVa
from coviddeaths de
join covidvaccinations va
	on de.location = va.location
    and de.date = va.date
where de.continent is not null
)
select *, (RollingPeopleVa/population)*100
from PopvsVa;

-- -- Creating view to store data
Create View percentages as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations,
	SUM(va.new_vaccinations) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From CovidDeaths de
Join CovidVaccinations va
	On de.location = va.location
    and de.date = va.date
where de.continent is not null