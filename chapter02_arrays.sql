-- Create a simple table to receive the contents of the tab-delimited example file in a siingle column.
CREATE TABLE tab_delimited_file(
  data_row TEXT);

-- Run a COPY command from psql to load the tab-delimited file into the table.
 \COPY tab_delimited_file FROM <path to source file WITH DELIMITER '!'
 
