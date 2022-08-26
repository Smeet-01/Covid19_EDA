----Basic Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Coviddeaths
WHERE continent is not null
ORDER BY 1,2



----Total Cases vs Total Deaths in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as  Death_Percentage
FROM Coviddeaths
WHERE location LIKE '%India%' 
ORDER BY 1,2




----Total Cases vs Population in India
SELECT location, date, total_cases, population, (total_cases/population * 100) as  Infected_Population_Percent
FROM Coviddeaths
WHERE continent is not null AND location LIKE '%India%'
ORDER BY 1,2




----Countries with the highest Infected Population to General Population Ratio
SELECT location, population, MAX(total_cases) AS Infected_Population, MAX((total_cases/population))*100 AS Infected_Population_Percent
FROM Coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infected_Population_Percent DESC




----Countries with Highest Death Count 
SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS Total_Death_Count
FROM Coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Total_Death_Count DESC




----Countries with Highest Death Percentage
SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS Total_Death_Count
FROM Coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Total_Death_Count DESC




----Total Deaths vs Population
SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS Total_Death_Count, MAX((total_deaths/population)*100) AS Death_Rate
FROM Coviddeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY Death_Rate DESC




----Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths, (SUM(CAST(new_deaths AS bigint))/SUM(new_cases))*100 AS Death_Percentage
FROM Coviddeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date




----Comparing Cases and Vaccinations
SELECT D.continent, D.location, D.date, D.population, D.new_cases, V.new_vaccinations
FROM Coviddeaths as D
JOIN Covidvaccinations as V 
ON D.location = V.location and D.date = V.date
WHERE D.continent is not NULL
ORDER BY D.location, D.date




----Vaccine Distribution in countries
SELECT D.continent, D.location, D.date, D.population, D.new_cases, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.date) as Rolling_Vaccinatons_distributed
FROM Project1..Coviddeaths as D
JOIN Project1..Covidvaccinations as V 
ON D.location = V.location and D.date = V.date
WHERE D.continent is not NULL
ORDER BY 2


----CTE 
WITH PopVsVac (continent, location, date, population, new_cases, new_vaccinations, Rolling_Vaccinations_distributed) 
as 
(
SELECT D.continent, D.location, D.date, D.population, D.new_cases, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.date) as Rolling_Vaccinatons_distributed
FROM Project1..Coviddeaths as D
JOIN Project1..Covidvaccinations as V 
ON D.location = V.location and D.date = V.date
WHERE D.continent is not NULL

)
SELECT *, (Rolling_Vaccinations_distributed/population)*100 AS Vax_distributed_per_100_pops
FROM PopVsVac


----Temp Table
 DROP TABLE if exists #PercentPoplationVaccinated
 CREATE TABLE #PercentPoplationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date Datetime,
 population numeric,
 new_vaccination numeric,
 Rolling_Vaccinations_distributed numeric
)

 INSERT INTO #PercentPoplationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.date) as Rolling_Vaccinatons_distributed
FROM Project1..Coviddeaths as D
JOIN Project1..Covidvaccinations as V 
ON D.location = V.location and D.date = V.date
WHERE D.continent is not NULL

SELECT *, (Rolling_Vaccinations_distributed/population)*100 AS Vax_distributed_per_100_pops
FROM #PercentPoplationVaccinated



----Creating a view 
CREATE VIEW
Vax_distributed_per_100_pops 
AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY D.location ORDER BY D.date) AS Rolling_Vaccinatons_distributed
FROM Project1..Coviddeaths AS D
Join Project1..Covidvaccinations AS V
	ON D.location = V.location and D.date = V.date
WHERE D.continent is not null 