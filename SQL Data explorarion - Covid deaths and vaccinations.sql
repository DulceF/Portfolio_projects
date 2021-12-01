Select *
From project1..Covid_deaths
order by 3,4

--Select *
--From project2..Covidvaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from project1..Covid_deaths
order by 1,2

--Looking at total cases vs total Deaths
--Shows the likelihood of dying if you contract Covid

select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from project1..Covid_deaths
Where location like '%United Kingdom%'
order by 1,2

--Shows what percentage of population got covid

select Location, date, total_cases,  Population, (total_cases/population)*100 as Infecction_rate
from project1..Covid_deaths
Where location like '%United Kingdom%'
order by 1,2

--Looking at countries with highest inffection rate compared to population

Select Location, Population, Max(total_cases) as Highest_infection_count, Max((total_cases/population))*100 as Percent_of_pop_infected
From project1..Covid_deaths
--Where location like '%United Kingdom%'
Group by Location, Population 
Order by Percent_of_pop_infected DESC;

--Showing countries with highest death count per population
--Issue with the data type NVARCHAR255 , so we need to change to integer (Max(cast(total_deaths as int))
Select Location, Max(cast(total_deaths as int)) as Total_death_count, Max(cast(total_cases as int)) as Highest_cases
From project1..Covid_deaths
Where continent is not null
Group by location
Order by Total_death_count Desc

--let's break things down by continent
select continent, max(cast(total_deaths as int)) as Total_death_count
from project1..Covid_deaths
where continent is not null
Group by continent
Order by Total_death_count desc

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage 
from project1..Covid_deaths
where continent is not null
Group by date
order by 1,2

--Looking at total population vs total vaccinations. Join tables (Because tables have the same location, date etc..)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Count_Big(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From project1..Covid_deaths dea
Join project1..Covid_vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVacc(Continent, Location, Date, Population, New_vaccinations, Rolling_vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Count_Big(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From project1..Covid_deaths dea
Join project1..Covid_vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (rolling_vaccinations/population)*100
From PopvsVacc

--TEMP TABLE

Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
rolling_vaccinations numeric
)

Create View Percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Count_Big(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
From project1..Covid_deaths dea
Join project1..Covid_vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From Percentpopulationvaccinated
