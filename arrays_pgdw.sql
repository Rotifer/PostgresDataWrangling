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
  UNNEST(header_row) column_titles,
  UNNEST(sample_data_row) sample_data
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
    
/*
Table for sub-set of loaded data.
*/
CREATE TABLE data_subset(
  data_subset_id SERIAL PRIMARY KEY,
  date_added DATE,
  pubmed_id INTEGER,
  first_author TEXT,
  study TEXT,
  snp_ids TEXT,
  reported_genes TEXT);
/*
Extract columns of interest from data,
 perform data casts as required  and
 load into table.
*/
INSERT INTO data_subset(date_added,
                        pubmed_id,
                        first_author,
                        study,
                        snp_ids,
                        reported_genes)
SELECT
  TO_DATE(data_elements[1], 'MM/DD/YYYY') date_added,
  data_elements[2]::int pubmed_id,
  data_elements[3] first_author,
  data_elements[7] study,
  data_elements[22] snp_ids,
  data_elements[14] reported_genes
FROM
  (SELECT
    STRING_TO_ARRAY(data_row, E'\t') data_elements
  FROM
    tab_delimited_file
  WHERE
    data_row NOT LIKE 'Date Added%') sq;
  
/*
Summary of SNP IDs per publication.
*/
CREATE OR REPLACE VIEW vw_pubmed_snps AS
SELECT
  pubmed_id,
  ARRAY_AGG(snp_ids) list_snp_ids
FROM
  data_subset
GROUP BY
  pubmed_id;

/*
Generate random data for simulation purposes.
*/
SELECT
  GENERATE_SERIES(1,1000) pk_id,
  (ARRAY_AGG(dates))[ROUND(RANDOM() * 365 + 1)] visit_date,
  (ARRAY['United States of America', 
         'United Kingdom', 
         'Mexico', 
         'Canada', 
         'Japan'])[ROUND(RANDOM() * 4 + 1)] country
FROM
  (SELECT
    DATE(GENERATE_SERIES('2014-01-01'::DATE,
                         '2014-12-31'::DATE,'1 day'))
                          dates) sq;   
