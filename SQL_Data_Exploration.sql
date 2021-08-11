SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows probability of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states'
ORDER by 1,2

-- Total Death Count per Continent
Select location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
and location not in ('World', 'Eiropean Union', 'International')
Group by location order by TotalDeathCount desc

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, total_cases, Population, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- WHERE Location like '%states'
ORDER by 1,2

--Looking at Countires with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/Population))*100 as
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP by Location, Population
ORDER by PercentPopulationInfected desc

SELECT Location, Population, date, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/Population))*100 as
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP by Location, Population, date
ORDER by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(CAST (Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY LOCATION 
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

Select continent, MAX(CAST (Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

Select continent, MAX(CAST (Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP by date
ORDER by 1,2


SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- TOTAL POPULATION VS VACCINATIONS
-- CTE
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVAccinated/Population)*100
FROM PopVsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO StORE DATA FOR LATER VISUALIZATIONS
DROP VIEW if exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS -- Will show up on Database/System Database/Master
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3