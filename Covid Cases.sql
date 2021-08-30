Select *
From ['COVID Deaths]
Where continent is not null
order by 3,4


--Select *
--From ['COVID Vaccinations]
--order by 3,4

Select location,date, total_cases,new_cases,total_deaths, population
From ['COVID Deaths]
Where continent is not null 
order by 1,2

-- looking at total cases vs deaths
Select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ['COVID Deaths]
Where location like '%states'
and continent is not null
order by 1,2


--looking at the total cases vs population
--shows what percentage of population got covid
Select location,date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From ['COVID Deaths]
--Where location like '%states'
order by 1,2

--looking at the countries with the highest infection rate
Select location,population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPercentage
From ['COVID Deaths]
Group by population, location
order by InfectedPercentage desc

--showing the countries with the highest death count per population
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From ['COVID Deaths]
Where continent is not null
Group by location
order by TotalDeathCount desc

--looking  at the total death count by continent
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From ['COVID Deaths]
where continent is null
Group by continent
Order by TotalDeathCount desc


--global numbers
Select date, Sum(new_cases) as TotalCases, SUm(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ['COVID Deaths]
where continent is not null
Group by date
order by 1,2



Select Sum(new_cases) as TotalCases, SUm(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ['COVID Deaths]
where continent is not null
--Group by date
order by 1,2

--check the vaccination table
Select *
from ['COVID Vaccinations]


-- total population vs vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ['COVID Deaths] dea
join ['COVID Vaccinations] vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from ['COVID Deaths] dea
join ['COVID Vaccinations] vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVID Deaths] dea
Join ['COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['COVID Deaths] dea
Join ['COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 