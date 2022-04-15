
--1. Highest Score match with date, team names and venue

--*********************************************************************--
-- THIS DATA ONLY PROVIDES HIGHEST SCORE OF WINNERS TEAM 

select  x.Match_Id, x.Teams,t.Team_Name as Winner,x.Match_Winner AS WinTeamID,x.TotalScore,x.Venue_Name AS Stadium,X.City,
datename(DD,x.Match_Date)+' '+datename(month,x.Match_Date)+' '+datename(YYYY,x.Match_Date) --or if we need datetype x.match_date
AS Match_Date from (select trs.Match_Id,m.Match_Winner,trs.TotalScore,MAX(t.Team_Name)+' VS '+MIN(t.Team_Name) AS Teams, m.Match_Winner AS Winner
,v.Venue_Name ,MAX(c.City_Name) AS City,m.Match_Date, ROW_NUMBER() over (partition by trs.match_id order by totalscore) as ROW,o.Outcome_Type from TotalScore_Valid_and_Extra trs
join Match m
on m.Match_Id=trs.Match_Id
join Venue v
on m.Venue_Id=v.Venue_Id
Join City C
on V.City_Id=C.City_Id
join Team t
on m.Team_1=t.Team_Id or m.Team_2=t.Team_Id 
join Outcome O
On o.Outcome_Id=m.Outcome_type
join Win_By WB
on WB.Win_Id=M.Win_Type
where O.Outcome_type<>'No Result' and WB.Win_Type NOT IN ('NO Result')
group by trs.Match_Id,o.Outcome_Type, trs.TotalScore, m.Team_1,m.Team_2, m.Match_Winner,v.Venue_name, m.Match_Date) x
join Team t
on t.Team_Id=x.Winner
where x.ROW=2 and x.Match_Id NOT IN ('336030','733998' , '392188' , '501250')  -- Match 336030 Stopped due to Rain and rest used D/L Method
order by TotalScore desc



--*********************************************************************--

--2. Lowest Score match with date, team Ids and venue

-- THIS DATA ONLY PROVIDES LOWEST SCORE OF LOOSER TEAM



select  x.Match_Id, x.Teams,t.Team_Name as Looser,x.LooserTeamID,x.TotalScore,x.Venue_Name AS Stadium,x.City,
datename(DD,x.Match_Date)+' '+datename(month,x.Match_Date)+' '+datename(YYYY,x.Match_Date) --or if we need datetype x.match_date
AS Match_Date from (select trs.Match_Id,trs.TotalScore,MAX(t.Team_Name)+' VS '+MIN(t.Team_Name) AS Teams,
case
when m.Team_1= m.Match_Winner
then m.Team_2
else m.Team_1
end as Looser,case
when m.Team_1= m.Match_Winner
then m.Team_2
else m.Team_1
end as LooserTeamID,v.Venue_Name ,MAX(c.City_Name) AS City,m.Match_Date, ROW_NUMBER() over (partition by trs.match_id order by totalscore) as ROW,o.Outcome_Type from TotalScore_Valid_and_Extra trs
join Match m
on m.Match_Id=trs.Match_Id
join Venue v
on m.Venue_Id=v.Venue_Id
Join City C
on V.City_Id=C.City_Id
join Team t
on m.Team_1=t.Team_Id or m.Team_2=t.Team_Id 
join Outcome O
On o.Outcome_Id=m.Outcome_type
join Win_By WB
on WB.Win_Id=M.Win_Type
where O.Outcome_type<>'No Result' and WB.Win_Type NOT IN ('NO Result')
group by trs.Match_Id,o.Outcome_Type, trs.TotalScore, m.Team_1,m.Team_2, m.Match_Winner,v.Venue_name, m.Match_Date) x
join Team t
on t.Team_Id=x.Looser
where x.ROW =1 and x.Match_Id NOT IN ('336030','733998' , '392188' , '501250')  -- Match 336030 Stopped due to Rain and rest used D/L Method
order by TotalScore asc


select * from Team

--*********************************************************************--
--3. Players who played most matches or Count of matches for each player



--each year
select PM.Player_Id AS PlayerID, p.Player_Name As Player, count(*) as NumberOfMatches,DATEPART(YEAR,M.Match_Date) AS Year from Player_Match PM
join Player P
on p.Player_Id=pm.Player_Id
Join Match M
on M.Match_Id=pm.Match_Id
group by pm.Player_Id, p.Player_Name, DATEPART(YEAR,M.Match_Date)
order by NumberOfMatches desc


select s.*,p.Player_Name from Season s
join Player p
on p.Player_Id=s.Man_of_the_Series



--*********************************************************************--
--4. Which team played most matches


select distinct T.Team_id AS TeamID, MAX(T.Team_Name) AS TeamName, count(distinct PM.Match_Id) AS NumberOfMatches from Player_Match PM
Join Team T
on T.Team_Id=PM.Team_Id
group by T.Team_Id
Order by NumberOfMatches desc

;





--PART 2 of the same question 4. Which team played most matches each year

select distinct T.Team_id AS TeamID, MAX(T.Team_Name) AS TeamName, count(distinct PM.Match_Id) AS NumberOfMatches,
DATEPART(YEAR,M.Match_Date) AS Year from Player_Match PM
Join Team T
on T.Team_Id=PM.Team_Id
Join Match M
on M.Match_Id=pm.Match_Id
group by T.Team_Id, DATEPART(YEAR,M.Match_Date)
Order by TeamName, Year

;




--*********************************************************************--
--5. Which venue has most matches

select M.Venue_Id ,count(*) As NumberOfMatches,MAX(V.Venue_Name) Stadium,
MAX(C.City_Name) City from Match M
join Venue V
on M.Venue_Id=V.Venue_Id
Join City C
on V.City_Id=C.City_Id
group by M.Venue_Id





--*********************************************************************--
--6. Which fielder caught maximum catches


select P.Player_Name AS Player, Count(*) AS NumberOfCatches from Wicket_Taken WT
Join Out_Type OT
ON WT.Kind_Out=OT.Out_Id
Join Player P
ON WT.Fielders=P.Player_Id
Where WT.Kind_Out=1
group by p.Player_Name
Order by NumberOfCatches DESC

--PART 2 of 6. Which fielder caught maximum catches Each Year


select P.Player_Name AS Player, Count(*) AS NumberOfCatches,DATEPART(YEAR,M.Match_Date) AS Year  from Wicket_Taken WT
Join Out_Type OT
ON WT.Kind_Out=OT.Out_Id
Join Player P
ON WT.Fielders=P.Player_Id
Join Match M
ON M.Match_Id=WT.Match_Id
Where WT.Kind_Out=1
group by p.Player_Name, DATEPART(YEAR,M.Match_Date)
Order by NumberOfCatches DESC





--*********************************************************************--
--7. Highest Number of Sixes

select BB.Striker as PlayerID,P.Player_Name AS Batsman, Count(*) AS NumberOfSixes from Batsman_Scored BS
 join ball_by_ball BB
ON BB.Ball_Id=BS.Ball_Id and BB.Match_Id=BS.Match_Id and bb.Over_Id=bs.Over_Id and BB.Innings_No=BS.Innings_No
join Player P
on P.Player_Id=BB.Striker
where Runs_Scored=6
group by Striker,Player_Name
order by NumberOfSixes DESC



--*********************************************************************--
--PART 2 of 7. Highest Number of Sixes each year



select BB.Striker as PlayerID,P.Player_Name AS Batsman, Count(*) AS NumberOfSixes, DATEPART(YEAR,M.Match_Date) AS Year from Batsman_Scored BS
 join ball_by_ball BB
ON BB.Ball_Id=BS.Ball_Id and BB.Match_Id=BS.Match_Id and bb.Over_Id=bs.Over_Id and BB.Innings_No=BS.Innings_No
join Player P
on P.Player_Id=BB.Striker
Join Match M
ON M.Match_Id=BB.Match_Id
where Runs_Scored=6
group by Striker,Player_Name, DATEPART(YEAR,M.Match_Date)
order by NumberOfSixes DESC


--*********************************************************************--
-------------------FINAL------------------------------------------------
--8. Highest scorer and lowest scorer



select BB.Striker as PlayerID,P.Player_Name AS Batsman, SUM(Runs_Scored) AS TotalRuns 
from Batsman_Scored BS
 join ball_by_ball BB
ON BB.Ball_Id=BS.Ball_Id and BB.Match_Id=BS.Match_Id and bb.Over_Id=bs.Over_Id and BB.Innings_No=BS.Innings_No
join Player P
on P.Player_Id=BB.Striker
group by Striker,Player_Name
order by TotalRuns DESC

--*********************************************************************--
--PART 2 of 8. Highest scorer and lowest scorer each year



select BB.Striker as PlayerID,P.Player_Name AS Batsman, SUM(Runs_Scored) AS TotalRuns,DATEPART(YEAR,M.Match_Date) AS Year 
from Batsman_Scored BS
 join ball_by_ball BB
ON BB.Ball_Id=BS.Ball_Id and BB.Match_Id=BS.Match_Id and bb.Over_Id=bs.Over_Id and BB.Innings_No=BS.Innings_No
join Player P
on P.Player_Id=BB.Striker
Join Match M
ON M.Match_Id=BB.Match_Id
group by Striker,Player_Name, DATEPART(YEAR,M.Match_Date)
order by TotalRuns DESC


--*********************************************************************--
/*** The following tables were the only tables created to facilitate the SQL Query for desired results, rest of the tables were called from the Database itself  ***/


select Match_Id, Innings_No, SUM(Runs_Scored) AS TotalValidScore into #TVS from Batsman_Scored
group by match_id, innings_no

select Match_Id, Innings_No, SUM(Extra_Runs) AS TotalExtraScore into #TES 
from Extra_Runs
group by match_id, innings_no

select * from #TVS order by Match_Id
select * from #TES order by Match_Id

Drop table if exists TotalScore_Valid_and_Extra
select v.Match_Id,v.Innings_No, isnull(TotalExtraScore,0)+isnull(TotalValidScore,0) AS TotalScore into TotalScore_Valid_and_Extra 
from #TVS V
full join #TES E
on e.Match_Id=v.Match_Id and e.Innings_No=v.Innings_No
where e.Innings_No=1 or e.Innings_No=2 -- Because Innings_No 3 or above are Super Overs
order by v.Match_Id
