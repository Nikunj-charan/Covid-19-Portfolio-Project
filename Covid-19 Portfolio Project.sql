use PortfolioProject
select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total case v/s Total deaths (per country)
-- probability of dying depending on where you're located

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100
as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to their population

select location,population,max(total_cases)as HighestInfectedCount,max(total_cases/population)*100 
as PercentageOfPeopleAffected
from CovidDeaths
where continent is not null
group by location,population
order by PercentageOfPeopleAffected desc

-- Looking at Highest Death count per Country

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- ANALYZING DATA BY CONTINENT

-- Looking at Highest Death count per Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Looking at Continents with Highest infection rate compared to their population.

select continent,max(total_cases)as HighestInfectedCount,max(total_cases/population)*100 
as PercentageOfPeopleAffected
from CovidDeaths
where continent is not null
group by continent
order by PercentageOfPeopleAffected desc

-- Looking at Total cases v/s Total deaths per continent

SELECT continent,SUM(total_cases) as total_cases,SUM(total_deaths) as total_deaths,
		(SUM(total_deaths) / NULLIF(SUM(total_cases), 0)) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC


-- GLOBAL NUMBERS & DATA

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
		SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
 where continent is not null
 order by 1,2

 -- Total Population fully vaccinated in each country

Select CD.location, Max(CV.people_fully_vaccinated) as TotalVaccinated
FROM CovidDeaths as CD
JOIN CovidVaccinations as CV
ON CD.location = CV.location AND CD.date = CV.date
where CD.continent is not null
GROUP BY CD.location
ORDER BY CD.location;


-- Percentage of people vaccinated in each country by using CTE

With PercentVaccinated AS 
(Select CD.location,MAX(CD.population) AS TotalPopulation,
        MAX(CV.people_fully_vaccinated) AS TotalVaccinated
From CovidDeaths AS CD
JOIN CovidVaccinations AS CV ON CD.location = CV.location AND CD.date = CV.date
Where CD.continent IS NOT NULL
Group by CD.location,CD.population)
Select location,TotalPopulation,TotalVaccinated,
Case When TotalVaccinated <> 0 THEN (TotalVaccinated/TotalPopulation) * 100
Else 0  -- or any default value you prefered by the data company
End as PercentageOfVaccinatedPeople
From PercentVaccinated
order by location

-- Creating Views for Data Visualization

-- Top 25 Highest Death rates by country

Create View HighestDeathPercentage as 
select Top 25 location, SUM(total_cases) as TotalInfected, 
			SUM(total_deaths) as TotalDeaths,
			(SUM(total_deaths)/SUM(total_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by location
order by DeathPercentage desc

 -- Covid Deaths Globally in each year
 
 Create view TotalDeathsEachYear as 
 Select YEAR(date) as YearOfCovid, SUM(total_deaths) as TotalDeaths
 from CovidDeaths
 group by YEAR(date)

 -- Death rate in each continent per year

 Create View DeathRatePerYear as
 Select continent, YEAR(date) as YearOfCovid, SUM(total_cases) as TotalCases,
		 SUM(total_deaths) as TotalDeaths,
		(SUM(total_deaths)/NULLIF(SUM(total_cases),0))*100 as DeathRate
 from CovidDeaths
 where continent is not null
 group by YEAR(date),continent

 