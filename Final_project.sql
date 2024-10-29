/* 
Covid 19 Data Exploration

Skills used : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, creating Views, Converting data types

*/

select * 
from CovidDeaths
where continent is not null
order by 3,4


-- Selecting the data that is required to start with

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- Total cases vs Total Deaths
-- shows the chance of death if you are diagonsed 

select location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths
where location = 'india'
and continent is not null
order by 1,2


-- Total Cases vs Total Populations
-- Shows the percentage of popilation infected

select location, date, total_cases, population, (total_cases/population)*100 as percentage_affected
from CovidDeaths
where continent is not null
order by 1,2


--Countries with highest infection rate compared to population

select location,population,max(total_cases) as Highestinfectioncount, max((total_cases/population))*100 as percentpopulationInfected
from CovidDeaths
where continent is not null
group by location,population
order by percentpopulationInfected desc

--countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
--Group By date
order by 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 PercentageVaccinated
From PopvsVac 




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 percentVaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


