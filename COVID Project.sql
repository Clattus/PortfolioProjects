-- SQL Data Exploration

-- CovidDeaths

SELECT * 
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--CovidVaccinations

SELECT * 
FROM sqlproject..CovidVaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--total Cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM sqlproject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--total cases vs population

SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM sqlproject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--countries with highest infection rate compared to population

SELECT location,population,Max(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM sqlproject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- by location

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM sqlproject..CovidDeaths
WHERE continent IS NULL
--WHERE location like '%India%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- continent with highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM sqlproject..CovidDeaths
WHERE continent IS NOT NULL
--Where location like '%India%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM sqlproject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST ( new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM sqlproject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Overall Percentage

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST ( new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM sqlproject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Joining CovidDeaths and CovidVaccination

SELECT *
FROM sqlproject..CovidDeaths death
JOIN sqlproject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date

-- total population vs vaccination
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations
	,SUM(CAST (vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.location ORDER BY  death.location,
	death.date) as PeopleVaccinated
FROM sqlproject..CovidDeaths death
JOIN sqlproject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

--CTE

WITH PopvsVac (continent, location, date,population,new_vaccinations,PeopleVaccinated)
AS 
(
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations
	,SUM(CONVERT (BIGINT, vacc.new_vaccinations )) OVER (PARTITION BY death.location ORDER BY  death.location,
	death.date) as PeopleVaccinated
FROM sqlproject..CovidDeaths death
JOIN sqlproject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (PeopleVaccinated / population)*100
FROM PopvsVac


-- TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations
	,SUM(CONVERT (BIGINT, vacc.new_vaccinations )) OVER (PARTITION BY death.location ORDER BY  death.location,
	death.date) as PeopleVaccinated
FROM sqlproject..CovidDeaths death
JOIN sqlproject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
--WHERE death.continent is not null
--ORDER BY 2,3

SELECT * , (PeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualiztion

CREATE View PercentPopulationVaccinated AS
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations
	,SUM(CONVERT (BIGINT, vacc.new_vaccinations )) OVER (PARTITION BY death.location ORDER BY  death.location,
	death.date) as PeopleVaccinated
FROM sqlproject..CovidDeaths death
JOIN sqlproject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated