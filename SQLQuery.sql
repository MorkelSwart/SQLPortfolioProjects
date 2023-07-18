Select * from PortfolioProject..CovidDeaths

-- Select Data to be used:

--Select Cast (total_deaths as Int) as total_deaths_conv From PortfolioProject..CovidDeaths 

--Select Location, date, new_cases, Convert (decimal,(Convert(int,total_deaths) / Convert(int,total_cases)))/100 as PercentageDeaths From 
--PortfolioProject..CovidDeaths order by PercentageDeaths desc

--Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths,(Convert(decimal, total_deaths)/convert(decimal, total_cases))*100 as PercentageDeaths 
From PortfolioProject..CovidDeaths where location like '%South Africa%'
order by 1,2

--Total Cases vs Population
Select Location, date, total_cases, population,(Convert(decimal, total_cases)/convert(decimal, population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths where location like '%states%'
order by 1,2

--Highest infection rates
Select Location, cast(population as float), Max(cast(total_cases as int)) as InfectionCount, (max(cast(total_cases as int))/cast(population as float))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths where continent is not null
Group by location,population
order by PercentagePopulationInfected desc

--Highest death rates
Select Location, population, Max(cast(total_deaths as int)) as DeathCount, (max(cast(total_deaths as int))/cast(population as float))*100 as PercentagePopulationDied
From PortfolioProject..CovidDeaths where continent is not null
Group by location,population
order by PercentagePopulationDied desc

-- Global Numbers
Select Location, date, total_cases, total_deaths,(Convert(decimal, total_deaths)/convert(decimal, total_cases))*100 as PercentageDeaths 
From PortfolioProject..CovidDeaths where continent is not null  
order by 1,2

--USe CTE
With PopVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
--Total rolling vaccinations
Select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
SUM(cast(vaccine.new_vaccinations as decimal)) Over (Partition by death.location order by death.location, death.date) as RollingVaccinationTotal 
from PortfolioProject..CovidDeaths as death Join PortfolioProject..CovidVaccination vaccine 
On death.location=vaccine.location and death.date=vaccine.date where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercantagePopVaccinated from PopVac

--TEMP table
Drop table if exists #PercentagePopVaccinated
Create Table #PercentagePopVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentagePopVaccinated 
--Total rolling vaccinations
Select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
SUM(cast(vaccine.new_vaccinations as decimal)) Over (Partition by death.location order by death.location, death.date) as RollingVaccinationTotal 
from PortfolioProject..CovidDeaths as death Join PortfolioProject..CovidVaccination vaccine 
On death.location=vaccine.location and death.date=vaccine.date where death.continent is not null
--order by 2,3

Select * from #PercentagePopVaccinated

--Create View to store data for later visualisations
Create View PercentagePopVaccinated as 
Select death.continent, death.location, death.date, population, vaccine.new_vaccinations, 
SUM(cast(vaccine.new_vaccinations as decimal)) Over (Partition by death.location order by death.location, death.date) as RollingVaccinationTotal 
from PortfolioProject..CovidDeaths as death Join PortfolioProject..CovidVaccination vaccine 
On death.location=vaccine.location and death.date=vaccine.date where death.continent is not null
--order by 2,3