-- not using full data for preserving desktop resources

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths;

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES TO TOTAL DEATHS
-- Likelihood of death in specific country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPct
From CovidDeaths
WHERE location = 'Greece'
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES TO POPULATION
Select Location, date, total_cases, population, (total_cases/population)*100 AS PopulationCOVID
From CovidDeaths
WHERE location = 'Greece'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Rate

Select Location, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- BY CONTINENT

Select continent, MAX(cast(Total_deaths as unsigned)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- total cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- OVER() command supported by newest version of MySQL

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
LEFT JOIN covidvaccinations vac 
	ON dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
LEFT JOIN covidvaccinations vac 
	ON dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



Create Temporary Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);



Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

