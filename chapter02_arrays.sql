-- Create a simple table to receive the contents of the tab-delimited example file in a siingle column.
CREATE TABLE tab_delimited_file(
  data_row TEXT);

-- Run a COPY command from psql to load the tab-delimited file into the table.
 \COPY tab_delimited_file FROM <path to source file> WITH DELIMITER '!'
 
/*
Turn each data row into an array and 
get the number of elements
*/
SELECT
  STRING_TO_ARRAY(data_row, E'\t'),
  ARRAY_LENGTH(STRING_TO_ARRAY(data_row, E'\t'), 1)
FROM
  tab_delimited_file;
