Select *
From PortfolioProject.dbo.CovidDeaths
Order By  3,4;

-- Select *
--  From PortfolioProject.dbo.CovidDeaths
-- Order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order By 1,2;

--Total cases vs Total deaths
--Likelhood of dying from contracting covid per country

Select location, date, total_cases, total_deaths, convert(float, total_deaths) /  convert(float, total_cases) * 100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location LIKE '%states%' or location LIKE '%nigeria%'
Order By 1,2;

--Total cases vs population
-- showing percentage of population that got covid
Select location, date, population, total_cases, convert(float, total_cases) / population * 100 AS PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where location LIKE '%states%' or location LIKE '%nigeria%'
Order By 1,2;

 --Countries with highest infection rate per population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent Is NOT Null
Group By location, population
Order By PercentPopulationInfected desc;

 --Countries with Highest Death count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent Is NOT Null
Group By location, population
Order By TotalDeathCount desc;

--Highest Deaths by continents

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent Is NOT Null
Group By continent
Order By TotalDeathCount desc;

--Total Deaths by continents
Select continent, sum(convert(float, total_deaths)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent Is NOT Null
Group By continent
Order By TotalDeathCount desc;

--Global Deaths
Select sum(convert(float, total_cases)) AS TotalCases, sum(convert(float, total_deaths)) AS TotalDeaths, sum(convert(float, total_deaths)) / sum(convert(float, total_cases))*100 AS GlobalDeathPercentage  
From PortfolioProject.dbo.CovidDeaths
WHere continent Is NOT Null
Order By 1,2; 


--Global Death Percentage over time
Select date, sum(convert(float, total_cases)) AS TotalCases, sum(convert(float, total_deaths)) AS TotalDeaths, sum(convert(float, total_deaths)) / sum(convert(float, total_cases))*100 AS GlobalDeathPercentage  
From PortfolioProject.dbo.CovidDeaths
Where continent Is NOT Null
Group by date
Order By 1,2;


 --Global Vac vs new Cases
 Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
 From PortfolioProject.dbo.CovidDeaths Dea
 Join PortfolioProject.dbo.CovidVaccinations Vac
 ON Dea.location = Vac.location
 And Dea.date = Vac.date
 Where Dea.continent Is NOT Null
Order By 2,3;

-- Total population vs  running total of vaccinations for each location, ordered by date.
Select Dea.continent, Dea.location, Dea.date, Dea.population,  Vac.new_vaccinations
, Sum(Convert(float, Vac.new_vaccinations)) Over(Partition By Dea.location Order By Dea.location, Dea.date) RunnungVaccinationTotal
 From PortfolioProject.dbo.CovidDeaths Dea
 Join PortfolioProject.dbo.CovidVaccinations Vac
 ON Dea.location = Vac.location
 And Dea.date = Vac.date
 Where Dea.continent Is NOT Null
Order By 2,3;

--Using CTE
With PopvsVac (Continent,Location, Date, Population, new_vaccinations, RunningVaccinationTotal)
As
(
Select Dea.continent, Dea.location, Dea.date, Dea.population,  Vac.new_vaccinations
, Sum(Convert(float, Vac.new_vaccinations)) Over(Partition By Dea.location Order By Dea.location, Dea.date) RunningVaccinationTotal
 From PortfolioProject.dbo.CovidDeaths Dea
 Join PortfolioProject.dbo.CovidVaccinations Vac
 ON Dea.location = Vac.location
 And Dea.date = Vac.date
 Where Dea.continent Is NOT Null
)
Select *, (RunningVaccinationTotal/Population)*100
From PopvsVac

--Temp Table
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population NUMERIC,
new_vaccinations NUMERIC,
RunningVaccinationTotal NUMERIC
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population,  Vac.new_vaccinations, Sum(Convert(float, Vac.new_vaccinations)) Over(Partition By Dea.location Order By Dea.location, Dea.date) RunningVaccinationTotal
From PortfolioProject.dbo.CovidDeaths Dea
Join PortfolioProject.dbo.CovidVaccinations Vac
ON Dea.location = Vac.location
And Dea.date = Vac.date
Where Dea.continent Is NOT Null

Select *, (RunningVaccinationTotal/Population)*100 As PercentPopulationVaccinated
From #PercentPopulationVaccinated


-- Creating VIews for Viz
Create View PercentPopulationVaccinated As
Select Dea.continent, Dea.location, Dea.date, Dea.population,  Vac.new_vaccinations, Sum(Convert(float, Vac.new_vaccinations)) Over(Partition By Dea.location Order By Dea.location, Dea.date) RunningVaccinationTotal
	 From PortfolioProject.dbo.CovidDeaths Dea
	 Join PortfolioProject.dbo.CovidVaccinations Vac
	 ON Dea.location = Vac.location
	 And Dea.date = Vac.date
	 Where Dea.continent Is NOT Null