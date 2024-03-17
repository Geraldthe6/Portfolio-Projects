Select *
From CovidVaccinations
where continent is not null
Order by 3,4

Select *
From CovidDeaths2
where continent is not null
Order by 3,4

--Select Data we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths2
Order by 1


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/NULLIF(cast(total_cases as float),0))*100 as Death_Percentage
From CovidDeaths2
where location = 'Nigeria'
Order by 1
------OR
--Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/ NULLIF(CONVERT(float,total_cases),0)) as Death_Percentage
--From CovidDeaths2
--Order by 1


--Looking at Total Cases vs Population
--shows what percentage of population got covid
Select Location, date, total_cases, population, (NULLIF(cast(total_cases as float),0))/(cast(population as float))*100 as Death_Percentage
From CovidDeaths2
where location = 'Nigeria'
Order by 1


--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(NULLIF(cast(total_cases as float),0))/(NULLIF(cast(population as float),0))*100 as PercentPopulationInfected
From CovidDeaths2
Group by location, population
Order by PercentPopulationInfected DESC

--Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX ((NULLIF(CONVERT(float,total_cases),0)))/ (NULLIF(CONVERT(float, population),0))*100 as PercentPopulationInfected
--From CovidDeaths2
--group by location, population
--Order by 1


--Showing Countries with highest Death Count per Population
Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths2
where continent <> ' '
Group by location
Order by TotalDeathCount DESC

--LET'S BREAK IT UP BY CONTINENT
--Showing Continent with highest deathcount
Select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths2
where continent = ' '
Group by location
Order by TotalDeathCount DESC


--GLOBAL NUMBERS
Select  SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(NULLIF(cast(new_deaths as float),0))/ SUM(NULLIF(cast(New_cases as float),0))*100 as DeathPercentage
From CovidDeaths2
--where location = 'Nigeria'
where continent <> ' '
--group by date
Order by 1

--JOINS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths2 dea
full Join CovidVaccinations vac
    On dea.date = vac.date
	and dea.location = vac.location
where dea.continent  is not null
--      and dea.date is not null
order by 2,3


--USE CTE

With PopsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths2 dea
full Join CovidVaccinations vac
    On dea.date = vac.date
	and dea.location = vac.location
where dea.continent <> ' '
--      and dea.date is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac



--TEMP TABLETABLE 
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RoolingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths2 dea
full Join CovidVaccinations vac
    On dea.date = vac.date
	and dea.location = vac.location
where dea.continent <> ' '
--      and dea.date is not null
order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated 

--CREATING VIEW TO STORE FOR LATER VISUALIZATION
WITH HighestInfectionRate (Location, Population, HighestInfectionCount, PercentPopulationInfected)
as
(
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(NULLIF(cast(total_cases as float),0))/(NULLIF(cast(population as float),0))*100 as PercentPopulationInfected
From CovidDeaths2
Group by location, population
--Order by PercentPopulationInfected DESC
)

Select *
From HighestInfectionRate

Create View HighestInfectionRate as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(NULLIF(cast(total_cases as float),0))/(NULLIF(cast(population as float),0))*100 as PercentPopulationInfected
From CovidDeaths2
Group by location, population
--Order by PercentPopulationInfected DESC
