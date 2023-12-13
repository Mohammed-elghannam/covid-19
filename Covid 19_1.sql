/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select *
From covid_death cd 
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_death 
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_death
Where location like '%egypt%'
and continent is not null 
order by 2 desc;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_death
Where location like '%egypt%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_death
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths ) as TotalDeathCount
From covid_death 
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From covid_death
Where  continent <> ''  
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From covid_death
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
with cte  as(
Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as  signed)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From covid_death cd 
Join covidvaccinations vac 
	On cd.location = vac.location
	and cd.date = vac.date
where cd.continent is not null 
order by 2,3
)
select continent,location, date, population, new_vaccinations,RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
from cte;

-- Using CTE to perform Calculation on Partition By in previous query

-- With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
-- as
-- (
-- Select cd.continent, cd.location, cd.date, cd.population, vac.new_vaccinations
-- , SUM(cast(vac.new_vaccinations as  signed)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
-- From covid_death cd 
-- Join covidvaccinations vac 
-- 	On cd.location = vac.location
-- 	and cd.date = vac.date
-- where cd.continent is not null 
-- order by 2,3
-- )
-- Select *, (RollingPeopleVaccinated/Population)*100
-- From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
Select cd.continent, cd.location, str_to_date(cd.date,'%m/%d/%Y')as date, cd.population, cast(vac.new_vaccinations as signed)
, SUM(CONVERT(vac.new_vaccinations,signed)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from covid_death cd
Join covidvaccinations  vac
	On cd.location = vac.location
	and cd.date = vac.date
-- where cd.continent is not null 
-- order by 2,3 
;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated; 





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, str_to_date(cd.date,'%m/%d/%Y')as date, cd.population, cast(vac.new_vaccinations as signed)
, SUM(CONVERT(vac.new_vaccinations,signed)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from covid_death cd
Join covidvaccinations  vac
	On cd.location = vac.location
	and cd.date = vac.date
where cd.continent is not null;

create view total_cases_deaths as 
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_death
where continent is not null 
order by 2 desc;

create view continent_total_death as
Select continent, MAX(Total_deaths) as TotalDeathCount
From covid_death
Where  continent <> ''  
Group by continent
order by TotalDeathCount desc;

create view Global_nubmer as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From covid_death
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;