-- Advanced SQL Project -- Spotify Data Set Analysis 

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA 

select count(*) from spotify;

select count (distinct artist) from spotify; 

select count (distinct album) from spotify; 

select distinct album_type from spotify; 

select min(duration_min) from spotify; 

select max(duration_min) from spotify; 


select * from spotify
where duration_min = 0 

delete from spotify 
where duration_min = 0 

select distinct channel from spotify; 

select distinct most_played_on from spotify;

-- Data Analysis 

-- Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify; 

select track, stream from spotify
where stream > 1000000000;

select count(track) from spotify
where stream > 1000000000;

-- List all albums along with their respective artists.

select distinct album, artist from spotify;

-- Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as total_comments from spotify
where licensed = 'true';

-- Find all tracks that belong to the album type single.

select track, album_type from spotify
where album_type ilike 'single';

-- Count the total number of tracks by each artist.

select artist, count(track) as total_tracks from spotify
group by artist
order by 2 desc; 

-- Calculate the average danceability of tracks in each album.


select avg(danceability) as avg_danceability, album from spotify  
group by album
order by avg_danceability desc;

-- Find the top 5 tracks with the highest energy values.

select distinct track, max(energy) from spotify
group by 1
order by 2 desc
limit 5;

-- List all tracks along with their views and likes where official_video = TRUE

select distinct track, sum(views), sum(likes) from spotify
where official_video = 'true'
group by 1
order by 2 desc;

-- For each album, calculate the total views of all associated tracks.
select sum(views) as total_views, album, track from spotify
group by album, track
order by total_views desc

-- Retrieve the track names that have been streamed on Spotify more than YouTube
select * from 
(select 
track, 
coalesce (sum(case when most_played_on = 'Youtube' then stream END), 0) as yt,
coalesce (sum(case when most_played_on = 'Spotify' then stream END), 0) as sp

from spotify 

group by track
) as subquery 

where sp > yt
and yt <> 0;

-- Find the top 3 most-viewed tracks for each artist using window functions

---using CTE

with subquery as  
(select 
artist, 
track,
sum (views) as total_view,
DENSE_RANK() OVER (PARTITION BY ARTIST ORDER BY sum(views) desc) as rank  
from spotify
group by 1,2 
order by 1,3 desc)
select * from subquery 
where rank <= 3


--Write a query to find tracks where the liveness score is above the average

select 
track, 
artist,
liveness 
from spotify 
where liveness > (select avg(liveness) from spotify)


-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with subquery as 
(select 

album, 
max(energy) as max_energy,
min(energy) as min_energy 
from spotify
group by 1) 
select max_energy - min_energy as energy_dif, album from subquery 
order by 1 desc

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.

select * from spotify 

with subquery as 
(select 
track,
liveness/energy as ratio
from spotify) 
select * from subquery 
where ratio >1.2
order by ratio 


-- Query optimisation 

explain analyze -- 7.87 ms pt 0.112 ms
select artist, track, views from spotify
where artist = 'Gorillaz'
and 
most_played_on = 'Youtube'
order by stream desc LIMIT 25

create index artist_index ON spotify (artist);

























