SELECT * 
FROM [Portfolio Project]..[covid deaths]
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..[covid vaccinations]
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..[covid deaths]
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[covid deaths]
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population contracted COVID

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentageofPopulationInfected
FROM [Portfolio Project]..[covid deaths]
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageofPopulationInfected
FROM [Portfolio Project]..[covid deaths]
GROUP BY Location, Population
ORDER BY PercentageofPopulationInfected DESC

--Looking at Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..[covid deaths]
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Looking at Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..[covid deaths]
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[covid deaths]
WHERE location like '%states%' and continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[covid deaths]
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.LOCATION, d.DATE) AS RollingPeopleVaccinated
FROM [Portfolio Project]..[covid deaths] d
JOIN [Portfolio Project]..[covid vaccinations] v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3;

--Use CTW

WITH PopVSvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.LOCATION, d.DATE) AS RollingPeopleVaccinated
FROM [Portfolio Project]..[covid deaths] d
JOIN [Portfolio Project]..[covid vaccinations] v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated
FROM PopVSvac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.LOCATION, d.DATE) AS RollingPeopleVaccinated
FROM [Portfolio Project]..[covid deaths] d
JOIN [Portfolio Project]..[covid vaccinations] v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.LOCATION, d.DATE) AS RollingPeopleVaccinated
FROM [Portfolio Project]..[covid deaths] d
JOIN [Portfolio Project]..[covid vaccinations] v
ON d.location = v.location and d.date = v.date
WHERE d.continent is not null
