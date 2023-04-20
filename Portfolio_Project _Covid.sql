Select *
FROM [Portfolio Proj].dbo.CovidDeaths$
where continent is not null
Order by 3,4

--Select *
--FROM [Portfolio Proj].dbo.CovidVaccinations$
--Order by 3,4

--Select data that we will be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Proj]..CovidDeaths$
Order by 1,2


--looking at total cases vs total deaths
-- shows the likelihood of dying if you get covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Proj]..CovidDeaths$
Where location like '%states%'
Order by 1,2



-- Looking at total cases vs Population
-- shows what percentage of population has covid
Select Location, date, Population, total_cases,(total_cases/population)*100 AS CovidPercentageInfected
From [Portfolio Proj]..CovidDeaths$
--Where location like '%africa%'
Order by 1,2

--which countries have highest infection rates compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCOunt,Max(total_cases/population)*100 AS CovidPercentageInfected
From [Portfolio Proj]..CovidDeaths$
--Where location like '%africa%'
Group by Location, Population
Order by CovidPercentageInfected DESC 


--showing the countries with highest mortality count by population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Proj]..CovidDeaths$
--Where location like '%africa%'
where continent is not null
Group by Location
Order by TotalDeathCount DESC 



--LETS BREAK THING DOWN BY CONTINENT for death count


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Proj]..CovidDeaths$
--Where location like '%africa%'
where continent is not null
Group by continent
Order by TotalDeathCount DESC 


-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths, SUM(Cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
From [Portfolio Proj]..CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
Order by 1,2



Select date, SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths, SUM(Cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
From [Portfolio Proj]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by date
Order by 1,2


--Vaccination Table, join two tables
--Looking at total population vs Vaccinations 
--SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)
--SAME AS SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location)



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVax
--,(RollingPeopleVax/population)*100
from [Portfolio Proj]..CovidDeaths$ dea
Join [Portfolio Proj]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE
--must have same amount of columns in with and select statement

With PopVsVac(Continent,Location,Date, Population, new_vaccinations, RollingPeopleVax)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVax
--,(RollingPeopleVax/population)*100
from [Portfolio Proj]..CovidDeaths$ dea
Join [Portfolio Proj]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select*,(RollingPeopleVax/population)*100
From PopVsVac


--TEMP TABLE


Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVax
--,(RollingPeopleVax/population)*100
from [Portfolio Proj]..CovidDeaths$ dea
Join [Portfolio Proj]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select*,(RollingPeopleVax/population)*100
From #PercentPopulationVaccinated


--TEMP TABLE
-- if you get an error message...
Drop Table if exists  #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVax
--,(RollingPeopleVax/population)*100
from [Portfolio Proj]..CovidDeaths$ dea
Join [Portfolio Proj]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select*,(RollingPeopleVax/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVax
--,(RollingPeopleVax/population)*100
from [Portfolio Proj]..CovidDeaths$ dea
Join [Portfolio Proj]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated