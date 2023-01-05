SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that will be used 
SELECT location, date, total_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths 
-- Likelihood of contracting covid
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%south%'
ORDER BY 1,2

-- Looking at the total cases vs  Population
-- Shows what percentage of population got COVID

SELECT location, date,population, total_cases, (total_cases/population) * 100 
AS infection_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)) * 100 AS infection_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 1,2 DESC

-- Break Things up by Continent

-- Highest death count per population

SELECT continent, MAX (CAST (total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC 

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- Looking at countries with highest death count per country

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (rolling_people_vaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (rolling_people_vaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
