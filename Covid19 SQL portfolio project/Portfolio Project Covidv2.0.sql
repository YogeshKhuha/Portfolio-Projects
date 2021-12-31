--We have two tables here CovidDeaths and CovidVaccinations
Select * from PortfolioProject.dbo.CovidDeaths

Select * from CovidVaccinations

--Select data that we will be using
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--breaking down likelihood of death if infected by covid by country

--Which countries have the most number of cases?
select location,max(total_cases) as MaxTotalCases
from CovidDeaths
where continent is not null
group by location
order by MaxTotalCases desc


--Which countries have most number of deaths?
select location,max(cast(total_deaths as int)) as MaxTotalDeaths
from CovidDeaths
where continent is not null
group by location
order by MaxTotalDeaths desc


--What are the death percetage for the infected population? (Total Cases vs Total Death percentage) 
Select location, MAX(total_cases) as max_total_cases, MAX(total_deaths) as max_total_deaths, (MAX(total_deaths)/MAX(total_cases)*100) as DeathPercentage
from CovidDeaths
where continent is not null
group by location
order by 4 desc


--What is death percentage if someone is covid infected in Canada?
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location = 'Canada'
order by 1,2

--Total cases vs Population
--What percentage of population was infected by covid ?
Select location, population, max(total_cases) as MaxTotalCases,  Max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
Where continent is not null
Group by location,population
order by PercentPopulationInfected desc

--Percent Population infected with time per country
Select location, population, date, max(total_cases) as MaxTotalCases,  Max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
Where continent is not null
Group by location,population, date
order by PercentPopulationInfected desc


--How much population has died because of Covid?
Select location, population, max(total_cases) as MaxTotalCases, max(cast(total_deaths as int)) as MaxTotalDeaths , 
(((max(cast(total_deaths as int)))/max(population))*100) as DeathPercentage
from CovidDeaths
Where continent is not null
Group by location,population
order by DeathPercentage desc


--Population death with time per country
Select location, population, date, max(cast(total_deaths as int)) as MaxTotalDeaths
from CovidDeaths
Where continent is not null
Group by location,population, date
order by MaxTotalDeaths desc


--create a temptable for continent data for later analysis
Drop table if exists #ContinentCovidDeaths 
Create table #ContinentCovidDeaths(
location nvarchar(255),
date datetime,
population float,
total_cases float,
total_deaths float
)

insert into #ContinentCovidDeaths
select location,date, population,total_cases,cast(total_deaths as float)
from CovidDeaths
where continent is null 
and location in ('Europe', 'Asia', 'South America', 'North America', 'Africa', 'Oceania')

select * from #ContinentCovidDeaths

--Breaking down Death count to continents
Select location, max(total_deaths) as MaxTotalDeaths
from #ContinentCovidDeaths
Group by location
order by MaxTotalDeaths desc

--What is number of population infected with covid per continent?
Select location, max(total_cases) as PopulationInfected
from #ContinentCovidDeaths
Group by location
order by PopulationInfected desc



--Global Scenario date wise
Select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100  as DeathPercentage
from CovidDeaths
Where continent is not null
Group by date
order by 1,2

--Global death percentage and infection percentage
select max(population) as population, max(total_cases) as max_total_cases, max(cast(total_deaths as int)) as max_total_deaths,
(max(total_cases)/max(population))*100 as PopulationInfected, 
(max(cast(total_deaths as int))/max(total_cases))*100 as DeathPercentage
from CovidDeaths
where location = 'World'



--Total population vs Vaccinations with date using CTE
with PopVsVac(continents, location, date,population, new_vaccinations, RollingPeopleVaccinated) as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated from PopVsVac



--temptable

Create table #PopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null


select *,(RollingPeopleVaccinated/population)*100 from #PopulationVaccinated


--Create view to store data for later
create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from PercentagePopulationVaccinated