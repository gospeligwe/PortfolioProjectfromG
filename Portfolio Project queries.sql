SELECT *
FROM [Portfolio Project]..CovidDeaths
ORDER BY 3,4

SELECT DISTINCT(continent)
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL

SELECT DISTINCT(location)
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL



SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths; shows the likehood of dying if you get infected

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%nigeria%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--shows what % of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%nigeria%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to Population
SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationAffected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL 
GROUP BY Location, Population, date
ORDER BY HighestInfectionCount DESC

--Showing countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%nigeria%'
WHERE continent IS NOT  NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population VS Vaccinations

WITH PopvsVac(Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN  [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PerPopVaccinated
FROM PopvsVac

---TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN  [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PerPopVaccinated
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN  [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated