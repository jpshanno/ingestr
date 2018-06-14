
<!-- README.md is generated from README.Rmd. Please edit that file -->
<img src="inst/img/logo_ingestr.png" align="right">

ingestr
=======

**An R package for reading environmental data from raw formats into data.frames.**

[![Travis-CI Build Status](https://travis-ci.org/jpshanno/ingestr.svg?branch=master)](https://travis-ci.org/jpshanno/ingestr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jpshanno/ingestr?branch=master&svg=true)](https://ci.appveyor.com/project/jpshanno/ingestr) [![Coverage Status](https://img.shields.io/codecov/c/github/jpshanno/ingestr/master.svg)](https://codecov.io/github/jpshanno/ingestr?branch=master)

This is project was initiated at the inagural [IMCR Hackathon](https://github.com/IMCR-Hackathon/HackathonCentral) hosted by the [Environmental Data Institute](https://environmentaldatainitiative.org/). The end product of this effort will be an R package on CRAN. The package will primarily deal with reading data from files, though there will be some utilities for initial cleanup of files such as removing blank rows and columns at the end of a CSV file. Our work at the hackathon focused on package infrastructure, standardization, and template construction.

The guiding principles of ingestr are that

1.  All sources of environmental-related data should be easy to read directly
2.  Reading in data should provide a standard output
3.  Header information contained within sensor data files should be stored in a standard, easily readable format
4.  Associating imported data with its original source is the first step towards good data provenance records and reproducibility
5.  We don't know about every common sensor and love contributions of code or sensors that need support. See [issues](https://github.com/jpshanno/ingestr/issues) to submit an example data file, and see our [contributing guide](https://github.com/jpshanno/ingestr/blob/master/CONTRIBUTING.md) to contribute code.

Installation
------------

You can install ingestr from github with:

``` r
# install.packages("devtools")
devtools::install_github("jpshanno/ingestr")
```

Ingesting Data
--------------

Each ingestr function to read in data starts with `ingest_` to make autocomplete easier.

Running any ingest function will read in the data and format the data into a clean R data.frame. Column names are taken directly from the data file, and users have the option to read the header information into a separate data frame in the environment where the function was called. A message and the data.frame structure will be printed to alert the user that the data.frame was created.
All data and header data that are read in will have the data source appended to the data as a column called input\_source.

### Sensor and Instrument Data

Many sensors provide their output as delimited files with header information contained above the recorded data.

``` r
library(ingestr)
campbell_file <- 
  system.file("example_data",
              "campbell_scientific_tao5.dat",
              package = "ingestr")

campbell_data <- 
  ingest_campbell(file.name = campbell_file,
                  add.units = TRUE,
                  add.measurements = TRUE,
                  header.info = TRUE,
                  header.info.name = "header_campbell")
#> The metadata were returned as the data.frame header_campbell
#> 'data.frame':    1 obs. of  8 variables:
#>  $ file_type               : chr "TOA5"
#>  $ logger_name             : chr "FRF_Village"
#>  $ logger_model            : chr "CR1000"
#>  $ logger_serial_number    : int 63162
#>  $ logger_os_version       : chr "CR1000.Std.27"
#>  $ logger_program_name     : chr "CPU:Complete Station_Bridget_31Oct2014.cr1"
#>  $ logger_program_signature: int 65292
#>  $ logger_table_name       : chr "Table_24"

str(campbell_data)
#> 'data.frame':    1272 obs. of  24 variables:
#>  $ TIMESTAMP                    : POSIXct, format: "2014-11-02" "2014-11-03" ...
#>  $ RECORD                       : int  0 1 2 3 4 5 6 7 8 9 ...
#>  $ Min_BattV_Min_Volts          : num  13.5 13.2 13.2 13.3 13.4 ...
#>  $ Max_PTemp_C_Max_Deg.C        : num  0.989 11.02 12.88 8.61 4.064 ...
#>  $ Min_PTemp_C_Min_Deg.C        : num  -3.32 -1.14 1.01 1.84 1.22 ...
#>  $ Avg_AirTC_Avg_Deg.C          : num  -2.042 3.432 5.348 3.808 0.677 ...
#>  $ Avg_RH_Avg_.                 : num  75 54.5 66.2 90.9 81.3 ...
#>  $ Avg_BP_kPa_Avg_kPa           : num  102 102 101 101 101 ...
#>  $ Tot_Rain_mm_Tot_mm           : num  0.73 2.482 0.146 2.044 0.438 ...
#>  $ Smp_Rain_24hr_mm             : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ Avg_WS_ms_Avg_meters.second  : num  0.266 0.843 0.579 0.919 0.698 ...
#>  $ WVc_WS_ms_S_WVT_meters.second: num  0.266 0.843 0.579 0.919 0.698 ...
#>  $ WVc_WindDir_D1_WVT_Deg       : num  167 186 176 263 293 ...
#>  $ WVc_WindDir_SD1_WVT_Deg      : num  31.3 36.9 49.3 46.9 57.8 ...
#>  $ Avg_VW_Avg                   : num  0.232 0.226 0.219 0.237 0.237 0.226 0.221 0.229 0.228 0.223 ...
#>  $ Avg_T107_C_Avg_Deg.C         : num  4.24 4.24 4.97 5.79 4.64 ...
#>  $ Avg_PAR_Den_Avg_umol.s.m.2   : num  0.031 122.7 105.3 16.6 34.72 ...
#>  $ Tot_PAR_Tot_Tot_mmol.m.2     : num  5.51e-01 1.06e+04 9.10e+03 1.43e+03 3.00e+03 ...
#>  $ Tot_SR01Up_Tot_W.m.2         : num  -542 7999 7999 7999 7999 ...
#>  $ Tot_SR01Dn_Tot_W.m.2         : num  507 7999 7999 2589 5394 ...
#>  $ Tot_IR01Up_Tot_W.m.2         : num  -7999 -7999 -7999 -208 -7999 ...
#>  $ Tot_IR01Dn_Tot_W.m.2         : num  -4385 -7999 -7999 -457 1520 ...
#>  $ Tot_NetTot_Tot_W.m.2         : num  -7999 7999 7999 7999 5115 ...
#>  $ input_source                 : chr  "C:/Users/whiteatl/Documents/R/R-3.5.0/library/ingestr/example_data/campbell_scientific_tao5.dat" "C:/Users/whiteatl/Documents/R/R-3.5.0/library/ingestr/example_data/campbell_scientific_tao5.dat" "C:/Users/whiteatl/Documents/R/R-3.5.0/library/ingestr/example_data/campbell_scientific_tao5.dat" "C:/Users/whiteatl/Documents/R/R-3.5.0/library/ingestr/example_data/campbell_scientific_tao5.dat" ...
```

### Formatted Non-Sensor Data Sources

Some environmental data is published online as html elements. This data can be difficult to read directly from the websites where they are hosted into R. To facilitate access, we have created functions that parse the html so that this data can be directly downloaded in R. To track the provenance of these data, the column input\_source is populated by the URL location from which the data were downloaded.

``` r
library(ingestr)

PDO_Data <- ingest_PDO(path = "http://jisao.washington.edu/pdo/PDO.latest",  
                       end.year = NULL,
                       header.info = TRUE,
                       header.info.name = "header_pdo")
#> 'data.frame':    1 obs. of  2 variables:
#>  $ input_source: Factor w/ 1 level "http://jisao.washington.edu/pdo/PDO.latest": 1
#>  $ table_header: Factor w/ 1 level "PDO INDEX If the columns of the table appear without formatting on your browser, use http://research.jisao.wash"| __truncated__: 1

str(PDO_Data)
#> 'data.frame':    119 obs. of  14 variables:
#>  $ YEAR        : chr  "1900" "1901" "1902" "1903" ...
#>  $ JAN         : num  0.04 0.79 0.82 0.86 0.63 0.73 0.92 -0.3 1.36 0.23 ...
#>  $ FEB         : num  1.32 -0.12 1.58 -0.24 -0.91 0.91 1.18 -0.32 1.02 1.01 ...
#>  $ MAR         : num  0.49 0.35 0.48 -0.22 -0.71 1.31 0.83 -0.19 0.67 0.54 ...
#>  $ APR         : num  0.35 0.61 1.37 -0.5 -0.07 1.59 0.74 -0.16 0.23 0.24 ...
#>  $ MAY         : num  0.77 -0.42 1.09 0.43 -0.22 -0.07 0.44 0.16 0.23 -0.39 ...
#>  $ JUN         : num  0.65 -0.05 0.52 0.23 -1.53 0.69 1.24 0.57 0.41 -0.64 ...
#>  $ JUL         : num  0.95 -0.6 1.58 0.4 -1.58 0.85 0.09 0.63 0.6 -0.39 ...
#>  $ AUG         : num  0.14 -1.2 1.57 1.01 -0.64 1.26 -0.53 -0.96 -1.04 -0.68 ...
#>  $ SEP         : num  -0.24 -0.33 0.44 -0.24 0.06 -0.03 -0.31 -0.23 -0.16 -0.89 ...
#>  $ OCT         : num  0.23 0.16 0.7 0.18 0.43 -0.15 0.08 0.84 -0.41 -0.02 ...
#>  $ NOV         : num  -0.44 -0.6 0.16 0.08 1.45 1.11 1.69 0.66 0.47 -0.4 ...
#>  $ DEC         : num  1.19 -0.14 -1.1 -0.03 0.06 -0.5 -0.54 0.72 1.16 -0.01 ...
#>  $ input_source: chr  "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" "http://jisao.washington.edu/pdo/PDO.latest" ...
```

### Batch Ingests

Sensor data stored in folders will be available for batch import using `ingest_` functions. Import functions will check for duplicate file contents and warn this users, and will allow parallel batch reading.

``` r
temperature_data <- 
  ingest_directory(dir = "temp_records",
                   fun = injest_campbell,
                   pattern = ".dat",
                   recursive = FALSE,
                   use.parallel = FALSE,
                   check.duplicates = "warn")
```

### Incorporate File Naming Conventions as Data

Filenames generally include information about the data collected: site, sensor, measurement type, date collected, etc. We are working on a generalized approach (probably just a function or two) that would split the filename into data columns using a template would be very useful.
For example if a set of file names read as "site-variable-year" (152-soil\_moisture-2017.csv, 152-soil\_temperature-2017.csv, 140-soil\_moisture\_2017.csv, etc), then the function would take an argument supplying the template as column headers: "site-variable-year" with either delimiters or the length of each variable to enable splitting. These functions will likely build off of the great work done on `tidyr::separate()` and we suggest using that until we have incoporated a solution.

Preliminary Clean-up Utilities
------------------------------

Basic data cleaning utilities will be included in ingestr. These will include identifying duplicate rows, empty rows, empty columns, and columns that contain suspicious entries (i.e. "."). These utilities will be able to flag or correct the problems depending upon user preference. In keeping with our commitment to data provenance and reproduciblity all cleaning utilties will provide a record of identified and corrected issues which can be saved by the user and stored with the final dataset.

QAQCR (quacker)
---------------

While ingestr is focused on getting data into R and running preliminary checks, another group at the IMCR Hackathon focused on quality assurance checks for envrinmental data. [qaqcr](https://github.com/IMCR-Hackathon/qaqc_tools) provides a simple, standard way to apply the quality control checks that are applicable to your data.

The packages are the start of a larger ecosystem including [EMLassemblyline](https://github.com/EDIorg/EMLassemblyline) for environmental data management to create a convienient, reproducible workflow moving from raw data to archived datasets with rich EML metadata.
