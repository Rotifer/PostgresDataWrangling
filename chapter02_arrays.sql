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

/*
Extract the first two rows as arrays.
Use the UNNEST function to turn the
 the array elements into rows.
*/
SELECT
  UNNEST(header_row),
  UNNEST(sample_data_row)
FROM
  (SELECT
    (SELECT
      STRING_TO_ARRAY(data_row, E'\t')
    FROM
      tab_delimited_file
    LIMIT 1) header_row,
    (SELECT
      STRING_TO_ARRAY(data_row, E'\t')
    FROM
      tab_delimited_file
    LIMIT 1 OFFSET 1)  sample_data_row) sq;
    
