use [PortfolioProjects]
Select * 
from PortfolioProjects..[Covid Deaths]
order by 3,4

Select * 
from PortfolioProjects..[Covid Vaccinations]
order by 3,4

-- We now select the data that will be used

Select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProjects..[Covid Deaths]
order by 1,2


-- Now the total cases will be looked at against the total deaths
-- this shows how likely a person will die when covid is contacted in Nigeria

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProjects..[Covid Deaths]
Where location like'%nigeria'
and continent is not null
order by 1,2

-- Now the total cases will be compared with the population
-- This shows the percentage of the population that has gotten covid

Select location, date, population, total_cases,  (total_cases/population)*100 as Casesercentage
from PortfolioProjects..[Covid Deaths]
Where location like'%nigeria'
order by 1,2

-- Viewing countires with highest infection rate compared to the population

Select location, population, Max(total_cases) as Infectioncount ,  Max((total_cases/population))*100 as MaxCasesercentage
from PortfolioProjects..[Covid Deaths]
--Where location like'%nigeria'
Group by location,population,continent
order by MaxCasesercentage desc


-- This shows Countries with the highest death count in relation to the population

Select location, Max(cast(total_deaths as int)) as MaxDeaths 
from PortfolioProjects..[Covid Deaths]
--Where location like'%nigeria'
Where continent is not null
Group by location
order by MaxDeaths desc


-- VISUALIZATION BASED ON CONTINENTS
-- This Shows the continent with the highest death count

Select continent, Max(cast(total_deaths as int)) as MaxDeaths 
from PortfolioProjects..[Covid Deaths]
--Where location like'%nigeria'
Where continent is not null
Group by continent
order by MaxDeaths desc


-- Global Calculations

Select date,Sum(new_cases)as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as newdeathpercentage
from PortfolioProjects..[Covid Deaths]
--Where location like'%nigeria'
where continent is not null
group by date
order by 1,2

--Accross the world in general

Select Sum(new_cases)as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as newdeathpercentage
from PortfolioProjects..[Covid Deaths]
--Where location like'%nigeria'
where continent is not null
--group by date
order by 1,2


-- USING THE JOINS
-- To retrive the total number of people in the qworld that has been vaccinated

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as CummulativeVacination
from PortfolioProjects..[Covid Deaths] dea
join PortfolioProjects..[Covid Vaccinations] vac -- Alias were added to the names to avoid typing the long names
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With popvsVac ( continent, location, Date, Population,New_Vaccinations,CummulativeVacination)
as
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as CummulativeVacination
from PortfolioProjects..[Covid Deaths] dea
join PortfolioProjects..[Covid Vaccinations] vac -- Alias were added to the names to avoid typing the long names
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(CummulativeVacination/Population)*100
from popvsVac

-- TEMP TABLE
Drop Table if exists  #percentpeoplevaccinated
Create Table #percentpeoplevaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CummulativeVaccination numeric
)

insert into #percentpeoplevaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as CummulativeVacination
from PortfolioProjects..[Covid Deaths] dea
join PortfolioProjects..[Covid Vaccinations] vac -- Alias were added to the names to avoid typing the long names
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *,(CummulativeVaccination/Population)*100
from  #percentpeoplevaccinated



-- Creating A view For data Future Visualizations and Storage

Create View  percentpeoplevaccinated as

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as CummulativeVacination
from PortfolioProjects..[Covid Deaths] dea
join PortfolioProjects..[Covid Vaccinations] vac -- Alias were added to the names to avoid typing the long names
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
from percentpeoplevaccinated