SELECT *
FROM SqlProject.dbo.LastPitchRays

SELECT *
FROM SqlProject.dbo.RaysPitchingStats

--Question 1: Avg pitches per at bat analysis

--1a: Avg pitches per at bat (LastPitchRays)

SELECT AVG(1.00 * pitch_number) as AvgNumofPitchesPerAtBat
FROM SqlProject.dbo.LastPitchRays

--1b: Avg pitches per at bat Home vs Away (LastPitchRays) -> Union

SELECT 
'Home' TypeofGame,
AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM SqlProject.dbo.LastPitchRays
WHERE home_team = 'TB'
UNION 
SELECT
'Away' TypeofGame,
AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM SqlProject.dbo.LastPitchRays
WHERE away_team = 'TB'

--1c: Avg pitches per at bat Lefty vs Righty -> Case Statement

SELECT 
AVG(CASE WHEN batter_pos = 'L' THEN  1.00 * pitch_number END) LeftyAtBats,
AVG(CASE WHEN batter_pos = 'R' THEN  1.00 * pitch_number END) RightyAtBats
FROM SqlProject.dbo.LastPitchRays

--1d: Avg pitches per at bat Lafty vs Righty | Each away game -> Partition by

SELECT DISTINCT
home_team,
pitcher_pos,
AVG(1.00 * pitch_number) OVER (PARTITION BY home_team, pitcher_pos)
FROM SqlProject.dbo.LastPitchRays
WHERE away_team = 'TB'

--1e: Top 3 most common pitch for at bat 1 through 10, and total amounts (LastPitchRays)

WITH totalpitchsequence as(
	SELECT DISTINCT
	pitch_name,
	pitch_number,
	COUNT(pitch_name) OVER (PARTITION BY pitch_name, pitch_number) PitchFrequency
	FROM SqlProject.dbo.LastPitchRays
	WHERE pitch_number <  11
),
pitchfrequencyrankquery as (
	SELECT
	pitch_name,
	pitch_number,
	PitchFrequency,
	rank() OVER (PARTITION BY pitch_number ORDER BY PitchFrequency desc) PitchFrequencyRanking
FROM totalpitchsequence
)
SELECT *
FROM pitchfrequencyrankquery
WHERE PitchFrequencyRanking < 4


--1f: Avg pitches per at bat per pitcher with 20+ innings | Order in descending (LastPitchRays + RaysPitchingStats)

SELECT 
RPS.Player, 
AVG(1.00 * pitch_number) AvgPitches
FROM SqlProject.dbo.LastPitchRays LPR
JOIN SqlProject.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
WHERE IP >= 20
GROUP BY RPS.Player
ORDER BY AVG(1.00 * pitch_number) DESC


--Question 2: Last Pitch Analysis 

--2a: Count of the last pitches thrown in desc order (LastPitchRays)

SELECT pitch_name, COUNT(*) timesthrown
FROM SqlProject.dbo.LastPitchRays
GROUP BY pitch_name
ORDER BY COUNT(*) DESC

--2b: Count of the different last pitches Fastball or Offspeed (LastPitchRays)

SELECT 
SUM(CASE WHEN pitch_name IN ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) Fastball,
SUM(CASE WHEN pitch_name NOT IN ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) Offball
FROM SqlProject.dbo.LastPitchRays

--2c: Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)

SELECT 
    ROUND(100.0 * SUM(CASE WHEN pitch_name IN ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) 
          / NULLIF(SUM(CASE WHEN pitch_name IS NOT NULL THEN 1 ELSE 0 END), 0), 0) AS Fastball_Percentage,
    ROUND(100.0 * SUM(CASE WHEN pitch_name NOT IN ('4-Seam Fastball', 'Cutter') THEN 1 ELSE 0 END) 
          / NULLIF(SUM(CASE WHEN pitch_name IS NOT NULL THEN 1 ELSE 0 END), 0), 0) AS Offball_Percentage
FROM SqlProject.dbo.LastPitchRays;

--2d: Top 5 Most common last pitch for a relief pitcher vs starting pitcher (LastPitchRays + RaysPitchingStats)

SELECT *
FROM(

	SELECT 
		a.Pos,
		a.pitch_name,
		a.timesthrown,
		RANK() OVER (PARTITION BY a.pos ORDER BY a.timesthrown DESC) PitchRank
	FROM (
		SELECT RPS.pos, LPR.pitch_name, COUNT(*) timesthrown
		FROM SqlProject.dbo.LastPitchRays LPR
		JOIN SqlProject.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
		GROUP BY RPS.pos, LPR.pitch_name
	) a
) b

WHERE b.PitchRank < 6

--Question 3: Homerun Analysis

--3a: What pitches have givenup the most HRs (LastPitchRays)

--SELECT *
--FROM SqlProject.dbo.LastPitchRays
--WHERE hit_location IS NULL AND bb_type = 'fly_ball'   (not working because of bad data)

SELECT pitch_name, COUNT(*) timesthrown
FROM SqlProject.dbo.LastPitchRays
WHERE events = 'home_run'
GROUP BY pitch_name
ORDER BY COUNT(*) DESC

--3b: Show HRs given up by zone and pitch, show top 5 most common

SELECT TOP 5 zone, pitch_name, COUNT(*) HRs
FROM SqlProject.dbo.LastPitchRays
WHERE events = 'home_run'
GROUP BY zone, pitch_name
ORDER BY COUNT(*) DESC

--3c: Show Hrs for each count type -> Balls/Strikes + Type of Pitcher

SELECT RPS.pos, LPR.balls, LPR.strikes, COUNT(*) HRs
FROM SqlProject.dbo.LastPitchRays LPR
JOIN SqlProject.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
WHERE events = 'home_run'
GROUP BY RPS.Pos, LPR.balls, LPR.strikes
ORDER BY COUNT(*) DESC


--3d: Show each Pitchers Most Common count to give up a HR (Min 30 IP)

WITH hrcountpitchers as (
	SELECT RPS.Player, LPR.balls, LPR.strikes, COUNT(*) HRs
	FROM SqlProject.dbo.LastPitchRays LPR
	JOIN SqlProject.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
	WHERE events = 'home_run' AND IP >= 30
	GROUP BY RPS.Player, LPR.balls, LPR.strikes
),
hrcountrank as (
	SELECT hcp.Player, hcp.balls, hcp.strikes, hcp.HRs,
	RANK() OVER (PARTITION BY Player ORDER BY HRs DESC) hrrank
	FROM hrcountpitchers hcp
)
SELECT ht.Player, ht.balls, ht.strikes, ht.HRs
FROM hrcountrank ht
WHERE hrrank = 1

--Question 4 Shane McClanahan
/*
SELECT RPS.Player, LPR.balls, LPR.strikes, COUNT(*) HRs
FROM SqlProject.dbo.LastPitchRays LPR
JOIN SqlProject.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
*/

--4a: Avg release speed, spin rate, strikeouts, most popular zone (only using LastPitchRays)

SELECT 
	AVG(release_speed) AvgReleaseSpeed,
	AVG(release_spin_rate) AvgSpinRAte,
	SUM(CASE WHEN events = 'strikeout' THEN 1 ELSE 0 END) strikeouts,
	MAX(zones.zone) AS Zone
FROM SqlProject.dbo.LastPitchRays LPR
JOIN(
	SELECT TOP 1 pitcher, zone, COUNT(*) zonenum
	FROM SqlProject.dbo.LastPitchRays LPR
	WHERE player_name = 'McClanahan, Shane'
	GROUP BY pitcher, zone
	ORDER BY COUNT(*) DESC
) zones ON zones.pitcher = LPR.pitcher
WHERE player_name = 'McClanahan, Shane'


--4b: Top pitches for each position where total pitches are over 5, rank them

SELECT *
FROM(
	SELECT pitch_name, COUNT(*) timeshit, 'Third' Position
	FROM SqlProject.dbo.LastPitchRays
	WHERE hit_location = 5 AND player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, COUNT(*) timeshit, 'Short' Position
	FROM SqlProject.dbo.LastPitchRays
	WHERE hit_location = 6 AND player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, COUNT(*) timeshit, 'Second' Position
	FROM SqlProject.dbo.LastPitchRays
	WHERE hit_location = 4 AND player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, COUNT(*) timeshit, 'First' Position
	FROM SqlProject.dbo.LastPitchRays
	WHERE hit_location = 3 AND player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
) a
WHERE timeshit > 4
ORDER BY timeshit DESC

--4c: Show different balls/strikes as well as frequency when someone is on base

SELECT balls, strikes, COUNT(*) frequency
FROM SqlProject.dbo.LastPitchRays
WHERE (on_1b IS NOT NULL OR on_2b IS NOT NULL OR on_3b IS NOT NULL)
AND player_name = 'McCLanahan, Shane'
GROUP BY balls, strikes
ORDER BY COUNT(*) DESC

--4d: What pitch causes the lowest launch speed

SELECT TOP 1 pitch_name, AVG(launch_speed * 1.00) LaunchSpeed
FROM SqlProject.dbo.LastPitchRays
WHERE player_name = 'McClanahan, Shane'
GROUP BY pitch_name
ORDER BY AVG(launch_speed)


