--SELECT *
--FROM [dbo].[CovidDeaths]
--ORDER by 3 ,4 

--SELECT *
--FROM [dbo].[CovidVaccinations]
--ORDER by 3 ,4 
  --Select the data that we are going to use

 Select Location, date , total_cases , new_cases , total_deaths, population
 FROM [dbo].[CovidDeaths]
 ORDER BY 1,2 

 -- Looking at total cases VS total deaths 
 -- Showing liklihood of dying if you have COVID in your country
 SELECT Location , date, total_cases,total_deaths,
 (total_cases/total_deaths)*100 as DeathsPrecentage
 FROM [dbo].[CovidDeaths]
 WHERE location like '%russia%'
 ORDER BY 1,2 
  
 -- The total Cases VS Population
 -- show what precentage of population got COVID

 SELECT Location , date, total_cases,
 (total_cases/population)*100 as PrecentofPopulationinfected
 FROM [dbo].[CovidDeaths]
 WHERE location like '%states%'
 ORDER BY 1,2 
  

 -- Countries with the highest infecation rate compared to population
  SELECT  location, population,MAX(total_cases) as HighestInfecationCount
 ,MAX((total_cases/population))*100 as PrecentPopulationInfected
 FROM [dbo].[CovidDeaths]
-- WHERE location like '%states%'
GROUP BY location,population
 ORDER BY PrecentPopulationInfected DESC

--Countries with the highest death count compared to population
 SELECT Location ,MAX(CAST(total_deaths as int))  as TotalDeaths
 FROM [dbo].[CovidDeaths]
 WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeaths DESC


SELECT continent ,MAX(CAST(total_deaths as int))  as TotalDeaths
 FROM [dbo].[CovidDeaths]
 WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeaths DESC

--Global numbers 

SELECT date ,SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as
total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM [dbo].[CovidDeaths]
 WHERE continent is not null 
GROUP BY date 
order by 1,2




SELECT SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as
total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
FROM [dbo].[CovidDeaths]
 WHERE continent is not null 
order by 1,2




with popVSvac(Continent , location , Date , Population , New_vaccinations , Rolling_people_vaccenated)
as
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by
dea.location, dea.date ) as Rolling_people_vaccenated 




FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac 
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
select * ,(Rolling_people_vaccenated/population) *100 as 
 the_precentage_of_the_people_who_got_vaccinated_in_the_country
from popVSvac


l

DROP TABLE IF EXISTS #PrecentPopulationVaccinated  
CREATE TABLE #PrecentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric ,
New_vaccinations numeric,
Rolling_people_vaccenated numeric
)


Insert into #PrecentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by
dea.location, dea.date ) as Rolling_people_vaccenated  
FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac 
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

select * ,(Rolling_people_vaccenated/population) *100 
FROM #PrecentPopulationVaccinated

--Creating view to store data for later visualizations

Create view  PrecentPopulationVaccinated as
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by
dea.location, dea.date ) as Rolling_people_vaccenated  
FROM [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac 
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
