# Updates the DB from 59 to 60 ~Qwertytoforty
# Makes a table for map picks

# Adds the table for it.
ALTER TABLE `player`
	ADD COLUMN `fptp_vote_list` MEDIUMTEXT NULL DEFAULT NULL AFTER `viewrange`;
