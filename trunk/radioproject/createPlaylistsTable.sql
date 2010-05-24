create table t_playlists (timestamp datetime not null, bandname text, songtitle text, station varchar(5) not null, constraint pk_TimestampStation Primary Key(timestamp,station));
