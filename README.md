# ingestr

An R package for reading environmental data from raw formats into dataframes. 

This is an alpha work in progress initiated at the inagural [IMCR Hackathon](https://github.com/IMCR-Hackathon/HackathonCentral).  The end product of this effort will be an R package on CRAN.  The package will primarily deal with reading data from files, though there will be some utilities for initial cleanup of files such as removing blank rows and columns at the end of a CSV file.

We're just getting started, so expect things to break!

# Reading in Files

Scientific data files are produced in many formats by many means. Here's what's on our radar.

* Sensors
    * [Campbell Scientific](https://www.campbellsci.com/blog/tool-to-import-data-to-r)
    * Solinst
    * iButton
    * EGM4 - todo
    * Hobo - todo
    * YSI - todo
    * others?
* Instrument Reports
    * Shimadzu
    * Horiba
    * Plate reader
* Non-sensor-originated data, organized by data source
    * HTML
        * https://www.esrl.noaa.gov/psd/enso/mei/table.html
        * http://research.jisao.washington.edu/pdo/PDO.latest
    * PDF
    * NetCDF
        * CF-compliant
        * Non-CF-compliant
    * Excel/Data notebook
    * Text/CSV/ASCII
    * Databases

# Helper Utilities

The package should be able to parse a single file or all files in a folder or zip file. If batch reading files then files should be checked for duplicate contents.

Assuming the user has set up several scripts in a folder for batch processing files, the package should support batch running all scripts in that folder.

The package should be able to extract information from filenames, such as station, date, variable, into columns within the data frame. For example if a set of file names read as "site-variable-year" (152-soil_moisture-2017, 152-soil_temperature-2017, 140-soil_moisture_2017, etc), then the function would take an argument supplying the template as column headers: "site-variable-year".

The package should be able to split a single column in the original data into multiple columns in the data frame, a la [tidyr](http://tidyr.tidyverse.org/).

# Cleanup Utilities

These are cleanup utilities that make sense to include in the data ingestion step.
* Remove blank rows and columns
* Find exact duplicates at the row level and flag or delete them
* Put datetimes in standard format.
    * ISO example datetime: 2018-06-12T16:33-06
  
# Provenance

Any function we make should record the source file as part of the data.

If data cleaning is performed, a separate data frame is output with three columns: the original filename, the line of text or data from the original file that was cleaned or removed, and the reason.
